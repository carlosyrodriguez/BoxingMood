import SwiftUI

// Theme model representing colors used across the app.
struct Theme: Identifiable, Equatable {
	var name: String
	var id: String { name }
	var primary: Color      // Used for prominent accents (originally red)
	var secondary: Color    // Used for secondary accents (originally yellow)
	var background: Color   // App background
	var text: Color         // General text color
	var cardBackground: Color
	var cardBorder: Color
}

/// A simple Theme manager. Themes are kept in memory and the selected theme name
/// is persisted to UserDefaults so selection survives relaunch.
final class ThemeManager: ObservableObject {
	@Published var themes: [Theme]
	@Published var selectedThemeName: String {
		didSet { UserDefaults.standard.set(selectedThemeName, forKey: "SelectedThemeName") }
	}

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

		self.themes = [defaultTheme]

		let saved = UserDefaults.standard.string(forKey: "SelectedThemeName")
		self.selectedThemeName = saved.flatMap { name in
			themes.first(where: { $0.name == name })?.name
		} ?? defaultTheme.name
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
	}

	func deleteTheme(at offsets: IndexSet) {
		// If deleting the selected theme, pick a sensible fallback
		let namesToRemove = offsets.map { themes[$0].name }
		themes.remove(atOffsets: offsets)

		if namesToRemove.contains(selectedThemeName) {
			selectedThemeName = themes.first?.name ?? ""
		}
	}
}

