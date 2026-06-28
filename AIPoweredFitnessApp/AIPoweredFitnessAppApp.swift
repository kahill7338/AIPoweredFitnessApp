//
//  AIPoweredFitnessAppApp.swift
//  AIPoweredFitnessApp
//
//  Created by kyle cahill on 2026-06-28.
//

import SwiftUI
import SwiftData

@main
struct AIPoweredFitnessAppApp: App {
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
        }
        .modelContainer(sharedModelContainer)
    }
}
