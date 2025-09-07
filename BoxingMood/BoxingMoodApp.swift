//
//  BoxingMoodApp.swift
//  BoxingMood
//
//  Created by Los on 3/23/25.
//

import SwiftUI
import SwiftData

@main
struct BoxingMoodApp: App {
    @StateObject private var themeManager = ThemeManager()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
