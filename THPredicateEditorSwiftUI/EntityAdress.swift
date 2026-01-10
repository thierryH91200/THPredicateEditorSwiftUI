//
//  Untitled.swift
//  THPredicateEditorSwiftUI
//
//  Created by thierryH24 on 03/01/2026.
//


import Foundation
import SwiftData

@Model
final class EntityAdress {
    @Attribute(.unique) var id: UUID = UUID()
    
    var town:String = ""
    var cp:String = ""

    @Relationship(deleteRule: .nullify) var personne: EntityPerson?

    public init() {}
}
