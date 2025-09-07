// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss // Used to close the sheet
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Apple ID Information Section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("Your Apple ID")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("example@apple.com") // Replace with actual Apple ID data if fetched
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                // MARK: - Other Settings Options (Placeholder)
                List {
                    Section(header: Text("Themes")) {
                        ForEach(themeManager.themes) { theme in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(theme.name)
                                        .fontWeight(.bold)
                                    Text("Preview")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(theme.primary)
                                    .frame(width: 36, height: 36)
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(theme.secondary, lineWidth: 2))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                themeManager.select(theme)
                            }
                        }
                        .onDelete { themeManager.deleteTheme(at: $0) }

                        HStack {
                            Button(action: { themeManager.addTheme() }) {
                                Label("Add Theme", systemImage: "plus")
                            }
                            Spacer()
                        }
                    }

                    Section(header: Text("Other")) {
                        Text("General")
                        Text("Notifications")
                        Text("Privacy")
                    }
                }
                .scrollDisabled(true) // Disable scrolling for the list itself if content is short
                .background(Color.clear) // Make list background transparent
                
                Spacer()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(Color.black.ignoresSafeArea()) // Black background for settings view
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
}
//  SettingsView.swift
//  BoxingMood
//
//  Created by Los on 9/5/25.
//
//


