//
//  GaslightApp.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI
import SwiftData

@main
struct GaslightApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JournalEntry.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If there's a migration issue, delete and recreate
            print("ModelContainer creation failed: \(error)")
            print("This is likely due to schema changes. Clearing data and recreating...")
            
            // Try to delete the old store and create a new one
            do {
                let url = URL.applicationSupportDirectory.appending(path: "default.store")
                try? FileManager.default.removeItem(at: url)
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even after cleanup: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
