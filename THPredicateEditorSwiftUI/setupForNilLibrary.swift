//
//  setupForNilLibrary.swift
//  PegaseUIData
//
//  Created by Thierry hentic on 10/11/2024.
//

import SwiftUI
import SwiftData
import Combine


@Observable
final class InitManager {
    
    static let shared = InitManager()
        
    
    // Contexte pour les modifications
    var modelContext: ModelContext? {
        DataContext.shared.context
    }

    private init() { }

    // Initialise la base si elle est vide
    @MainActor func initialize() {

        // Déterminer si des dossiers existent déjà (critère: isRoot == false)
        let entities = PersonManager.shared.getAllData()
        guard entities.isEmpty == true else {
            // Déjà initialisé
            return
        }
        setupDefaultLibrary()
    }
    
    @MainActor func setupDefaultLibrary() {
//        guard let ctx = modelContext else {
//            printTag("InitManager.setupDefaultLibrary: ModelContext indisponible.", flag: true)
//            return
//        }
        
        
        
        
    }
    
    func saveContext() {
    }
}
