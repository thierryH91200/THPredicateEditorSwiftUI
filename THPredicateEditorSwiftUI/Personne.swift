//
//  Item.swift
//  THPredicateEditorSwiftUI
//
//  Created by thierryH24 on 30/12/2025.
//

import Foundation
import SwiftData

@Model
final class Personne {
    @Attribute(.unique) var id: UUID
    var firstName:String = ""
    var lastName:String = ""
    var dateOfBirth = Date()
    var age = 0
    var department = ""
    var country = ""
    var isBool = false

    init() {
        self.id = UUID()
    }
}
