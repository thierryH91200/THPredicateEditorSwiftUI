//
//  Oerson.swift
//  THPredicateEditorSwiftUI
//
//  Created by thierryH24 on 30/12/2025.
//

import AppKit
import SwiftUI

@objcMembers
class Person : NSObject {
    var firstName:String
    var lastName:String
    var dateOfBirth = Date()
    var age = 0
    var department = ""
    var country = ""
    var isBool = false
    
    override init() {
        firstName = "given"
        lastName = "family"
        super.init()
    }
    
    
    init(firstName:String, lastName:String, dateOfBirth : Date, age:Int, department : String, country : String, isBool: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.age = age
        self.department = department
        self.country = country
        self.isBool = isBool
        super.init()
    }
    
    private func emojiFlag(countryCode: String) -> String {
        var string = ""
        let country = countryCode.uppercased()
        for uS in country.unicodeScalars {
            if let scalar = UnicodeScalar(127_397 + uS.value) {
                string.append(String(scalar))
            }
        }
        return string
    }

}

