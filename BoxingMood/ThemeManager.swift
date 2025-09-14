import SwiftUI
import UIKit

// Theme model representing colors used across the app.
struct Theme: Identifiable, Equatable {
	var name: String
	var id: String { name }
	var primary: Color      // Prominent accents
	var secondary: Color    // Secondary accents
	var background: Color   // App background
	var text: Color         // General text color
	var cardBackground: Color
	var cardBorder: Color
}

// Persisted lightweight representation of a Theme
private struct PersistedTheme: Codable {
	let name: String
	let primaryHex: String
	let secondaryHex: String
	let backgroundHex: String
	let textHex: String
	let cardBackgroundHex: String
	let cardBorderHex: String
}

/// A simple Theme manager. Themes are kept in memory and the selected theme name
/// is persisted to UserDefaults so selection survives relaunch.
final class ThemeManager: ObservableObject {
	@Published var themes: [Theme]
	@Published var selectedThemeName: String {
		didSet { UserDefaults.standard.set(selectedThemeName, forKey: "SelectedThemeName") }
	}

	private let themesKey = "SavedThemesV1"

	init() {
		// Default theme matches the app's current colors/layout
		let defaultTheme = Theme(
			name: "Default",
			primary: .red,
			secondary: .yellow,
			background: Color.yellow,
			text: Color.black,
			cardBackground: Color(.systemBackground).opacity(0.6),
			cardBorder: Color.white.opacity(0.2)
		)

		// A dynamic monochrome theme that adapts to light/dark mode
		let monoPrimary = Color(UIColor { tc in tc.userInterfaceStyle == .dark ? .white : .black })
		let monoSecondary = Color(UIColor { tc in tc.userInterfaceStyle == .dark ? UIColor(white: 0.8, alpha: 1) : UIColor(white: 0.2, alpha: 1) })
		let monoBackground = Color(UIColor { tc in tc.userInterfaceStyle == .dark ? UIColor(white: 0.06, alpha: 1) : .white })
		let monoText = Color(UIColor { tc in tc.userInterfaceStyle == .dark ? .white : .black })
		let monoCardBG = Color(UIColor { tc in tc.userInterfaceStyle == .dark ? UIColor(white: 0.08, alpha: 0.6) : UIColor(white: 1.0, alpha: 0.95) })
		let monoCardBorder = Color(UIColor { tc in tc.userInterfaceStyle == .dark ? UIColor(white: 1, alpha: 0.06) : UIColor(white: 0, alpha: 0.06) })

		let monochromeTheme = Theme(
			name: "Monochrome",
			primary: monoPrimary,
			secondary: monoSecondary,
			background: monoBackground,
			text: monoText,
			cardBackground: monoCardBG,
			cardBorder: monoCardBorder
		)

		// Build initial themes locally first to avoid capturing `self` in closures
	let initialThemes = [defaultTheme, monochromeTheme]
	self.themes = initialThemes

		let saved = UserDefaults.standard.string(forKey: "SelectedThemeName")
	// Make Monochrome the default theme if no saved selection
	let selected = initialThemes.first(where: { $0.name == saved })?.name ?? monochromeTheme.name
	self.selectedThemeName = selected

		// Load persisted themes (merge with built-ins)
		if let data = UserDefaults.standard.data(forKey: themesKey),
		   let decoded = try? JSONDecoder().decode([PersistedTheme].self, from: data) {
			let converted = decoded.map { p in
				Theme(
					name: p.name,
					primary: Color(hex: p.primaryHex),
					secondary: Color(hex: p.secondaryHex),
					background: Color(hex: p.backgroundHex),
					text: Color(hex: p.textHex),
					cardBackground: Color(hex: p.cardBackgroundHex),
					cardBorder: Color(hex: p.cardBorderHex)
				)
			}
			self.themes.append(contentsOf: converted)
		}
	}

	var currentTheme: Theme {
		themes.first(where: { $0.name == selectedThemeName }) ?? themes[0]
	}

	func select(_ theme: Theme) {
		selectedThemeName = theme.name
	}

	func addTheme(copyFrom: Theme? = nil) {
		let base = copyFrom ?? currentTheme
		var newName = "New Theme"
		var i = 1
		while themes.contains(where: { $0.name == newName }) {
			i += 1
			newName = "New Theme \(i)"
		}

		// Convert base Colors to hex strings for persistence
		let newTheme = Theme(
			name: newName,
			primary: base.primary,
			secondary: base.secondary,
			background: base.background,
			text: base.text,
			cardBackground: base.cardBackground,
			cardBorder: base.cardBorder
		)

		themes.append(newTheme)
		selectedThemeName = newTheme.name

		persistThemes()
	}

	func deleteTheme(at offsets: IndexSet) {
		// If deleting the selected theme, pick a sensible fallback
		let namesToRemove = offsets.map { themes[$0].name }
		themes.remove(atOffsets: offsets)

		if namesToRemove.contains(selectedThemeName) {
			selectedThemeName = themes.first?.name ?? ""
		}

		persistThemes()
	}

	private func persistThemes() {
		// Persist user-added themes (exclude built-in first two)
		let custom = themes.dropFirst(2)
		let persisted = custom.map { t in
			PersistedTheme(
				name: t.name,
				primaryHex: t.primary.toHex() ?? "FF0000FF",
				secondaryHex: t.secondary.toHex() ?? "FFFF00FF",
				backgroundHex: t.background.toHex() ?? "FFFFFFFF",
				textHex: t.text.toHex() ?? "000000FF",
				cardBackgroundHex: t.cardBackground.toHex() ?? "FFFFFFFF",
				cardBorderHex: t.cardBorder.toHex() ?? "00000026"
			)
		}
		if let data = try? JSONEncoder().encode(persisted) {
			UserDefaults.standard.set(data, forKey: themesKey)
		}
	}

	// MARK: - Export / Import Support
	/// Export all themes (including built-ins) as JSON data of PersistedTheme array.
	func exportThemesData() -> Data? {
		let persisted = themes.map { t in
			PersistedTheme(
				name: t.name,
				primaryHex: t.primary.toHex() ?? "FF0000FF",
				secondaryHex: t.secondary.toHex() ?? "FFFF00FF",
				backgroundHex: t.background.toHex() ?? "FFFFFFFF",
				textHex: t.text.toHex() ?? "000000FF",
				cardBackgroundHex: t.cardBackground.toHex() ?? "FFFFFFFF",
				cardBorderHex: t.cardBorder.toHex() ?? "00000026"
			)
		}
		return try? JSONEncoder().encode(persisted)
	}

	/// Write exported themes to a temporary file and return its URL for sharing.
	func exportThemesToFile() -> URL? {
		guard let data = exportThemesData() else { return nil }
		let url = FileManager.default.temporaryDirectory.appendingPathComponent("BoxingMood-Themes.json")
		do {
			try data.write(to: url, options: .atomic)
			return url
		} catch {
			return nil
		}
	}

	/// Import themes from JSON data. Returns number of themes imported.
	@discardableResult
	func importThemes(from data: Data) -> Int {
		guard let decoded = try? JSONDecoder().decode([PersistedTheme].self, from: data) else { return 0 }
		var added = 0
		for p in decoded {
			if themes.contains(where: { $0.name == p.name }) { continue }
			let t = Theme(
				name: p.name,
				primary: Color(hex: p.primaryHex),
				secondary: Color(hex: p.secondaryHex),
				background: Color(hex: p.backgroundHex),
				text: Color(hex: p.textHex),
				cardBackground: Color(hex: p.cardBackgroundHex),
				cardBorder: Color(hex: p.cardBorderHex)
			)
			themes.append(t)
			added += 1
		}
		if added > 0 { persistThemes() }
		return added
	}

	/// Import themes from a file URL (reads data then calls importThemes(from:)).
	@discardableResult
	func importThemes(from url: URL) -> Int {
		guard let data = try? Data(contentsOf: url) else { return 0 }
		return importThemes(from: data)
	}
}

// MARK: - Color <-> Hex helpers
extension Color {
	init(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hex).scanHexInt64(&int)
		let a, r, g, b: UInt64
		switch hex.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (255, 0, 0, 0)
		}
		self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
	}

	// Attempt to get a hex representation of a Color (returns RGBA hex)
	func toHex() -> String? {
		#if canImport(UIKit)
		let ui = UIColor(self)
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
		guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
		let ri = UInt8(r * 255)
		let gi = UInt8(g * 255)
		let bi = UInt8(b * 255)
		let ai = UInt8(a * 255)
		return String(format: "%02X%02X%02X%02X", ai, ri, gi, bi)
		#else
		return nil
		#endif
	}

}

