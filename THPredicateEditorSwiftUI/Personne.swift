//
//  Item.swift
//  THPredicateEditorSwiftUI
//
//  Created by thierryH24 on 30/12/2025.
//

import Foundation
import SwiftData

@Model
final class EntityPerson {
    @Attribute(.unique) var id: UUID
    var firstName:String = ""
    var lastName:String = ""
    var dateOfBirth = Date()
    var age = 0
    var department = ""
    var country = ""
    var isBool = true

    init() {
        self.id = UUID()
    }
    
    init(firstName:String, lastName:String, dateOfBirth : Date, age:Int, department : String, country : String, isBool: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.age = age
        self.department = department
        self.country = country
        self.isBool = isBool
        self.id = UUID()
    }

}

protocol PersonManaging {
    func create() throws -> EntityPerson
    func getAllData() -> [EntityPerson]
    func delete(entity: EntityPerson, undoManager: UndoManager?)
    func save() throws
}

final class PersonManager: PersonManaging {
    
    static let shared = PersonManager()
    var entities = [EntityPerson]()
    
    var modelContext: ModelContext? {
        DataContext.shared.context
    }
    
    init() { }
    
    func create() throws -> EntityPerson {
        var entity = EntityPerson()

        return entity
    }
    
    
    func getAllData() -> [EntityPerson] {
        guard let modelContext else {
            print("ModelContext non configuré")
            return []
        }

        let sort = [SortDescriptor(\EntityPerson.lastName, order: .forward)]
        let fetchDescriptor = FetchDescriptor<EntityPerson>(sortBy: sort)

        do {
            entities = try modelContext.fetch(fetchDescriptor)
            return entities
        } catch {
            print("Erreur lors de la récupération des données : \(error)")
            return []
        }
    }
    
    func delete(entity: EntityPerson, undoManager: UndoManager?) {
        guard let modelContext = modelContext else { return }

        modelContext.undoManager = undoManager
        modelContext.undoManager?.beginUndoGrouping()
        modelContext.undoManager?.setActionName("Delete EntityPerson")
        modelContext.delete(entity)
        modelContext.undoManager?.endUndoGrouping()
    }


    func save() throws {
        do {
            try modelContext?.save()
        } catch {
            throw EnumError.saveFailed
        }
    }

}

enum EnumError: Error {
    case contextNotConfigured
    case accountNotFound
    case invalidStatusType
    case saveFailed
    case fetchFailed
}

