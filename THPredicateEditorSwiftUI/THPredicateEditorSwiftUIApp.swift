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
    @StateObject private var containerManager = ContainerManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(containerManager)
        }
    }
}

final class AppSchema {
    static let shared = AppSchema()
    
    let schema = Schema([
        EntityPerson.self,
    ])
    
    private init() {}
}

