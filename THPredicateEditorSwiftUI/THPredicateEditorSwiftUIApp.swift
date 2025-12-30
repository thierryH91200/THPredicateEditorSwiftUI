//
//  THPredicateEditorSwiftUIApp.swift
//  THPredicateEditorSwiftUI
//
//  Created by thierryH24 on 30/12/2025.
//

import SwiftUI
import SwiftData

@main
struct THPredicateEditorSwiftUIApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Personne.self,
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
            HybridContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
