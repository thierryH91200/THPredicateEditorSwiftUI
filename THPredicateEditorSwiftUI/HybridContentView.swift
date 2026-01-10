import SwiftUI
import Combine
import AppKit

import SwiftData
import SwiftDate



struct HybridContentData: View {
    @StateObject private var vm = HybridViewModel()
    
    @Environment(\.modelContext) private var modelContext
    @Query private var allPersons: [EntityPerson]
    @State private var displayedPersons: [EntityPerson] = []
    
    @State private var parsedSwiftDataPredicate: String = ""

    @State private var isFiltered = false

    @State private var currentPredicate: NSPredicate?


    var body: some View {
        VStack(spacing: 0) {
            // NSPredicateEditor embedded in SwiftUI
    #if os(macOS)
            
            NSPredicateEditorView(
                predicate: $currentPredicate,
                onPredicateChange: applyPredicate
            )
    #else
            Text("Predicate Editor available on macOS")
                .padding(.bottom, 12)
    #endif
            
            VStack(spacing: 12) {
                Text(currentPredicate?.predicateFormat ?? "Aucun prédicat")
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                HStack {
                    Text(vm.swiftDataPredicate(from: vm.predicate) != nil ? "Parsed → OK" : "Parsed → nil")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
    #if DEBUG
                    Spacer()
                    Button("Log Predicates") {
                        print("NSPredicate:", vm.predicate?.predicateFormat ?? "nil")
                        let parsed = vm.swiftDataPredicate(from: vm.predicate)
                        print("SwiftData Predicate:", parsed != nil ? "OK" : "nil")
                    }
                    .buttonStyle(.bordered)
    #endif
                }

                Table(displayedPersons) {
                    TableColumn("First Name") { Text(String($0.firstName)) }
                    TableColumn("Last Name") { Text(String($0.lastName)) }
                    TableColumn("Age") { Text(String($0.age)) }
                    TableColumn("Country") { Text(String($0.country)) }
                    TableColumn("Department") { Text(String($0.department)) }
                    TableColumn("Bool") { Text($0.isBool ? "true" : "false") }
                    TableColumn("Date of birth") {
                        Text($0.dateOfBirth.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }
            .padding()
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private func applyPredicate() {
        guard let predicate = currentPredicate else {
            clearPredicate()
            return
        }
        
        print("=== APPLY PREDICATE ===")
        print("NSPredicate: \(predicate)")
        print("Predicate format: \(predicate.predicateFormat)")
        
        // Vérifier que le prédicat est complet
        let predicateString = predicate.predicateFormat
        if predicateString.isEmpty || predicateString.contains("nil") {
            print("Predicate incomplete, skipping filter")
            return
        }
        
        // Filtrer les personnes en convertissant chaque personne en dictionnaire
        displayedPersons = allPersons.filter { person in
            let dict: [String: Any] = [
                "firstName": person.firstName,
                "lastName": person.lastName,
                "age": person.age,
                "department": person.department,
                "country": person.country,
                "isBool": person.isBool,
                "dateOfBirth": person.dateOfBirth
            ]
            
            return predicate.evaluate(with: dict)
        }
        
        // Convertir en SwiftData predicate
        parsedSwiftDataPredicate = convertToSwiftDataPredicate(predicate)
        print(parsedSwiftDataPredicate)
        
        isFiltered = true
        
        print("Filtered: \(displayedPersons.count) / \(allPersons.count)")
    }
    
    private func clearPredicate() {
        currentPredicate = nil
        displayedPersons = allPersons
        parsedSwiftDataPredicate = ""
        isFiltered = false
    }
    
    private func convertToSwiftDataPredicate(_ predicate: NSPredicate) -> String {
        let predicateString = predicate.predicateFormat
        
        // Conversion basique du format NSPredicate vers SwiftData
        var converted = predicateString
        
        // Remplacer les noms de clés par person.property
        let properties = ["firstName", "lastName", "age", "department", "country", "isBool", "dateOfBirth"]
        for property in properties {
            converted = converted.replacingOccurrences(of: property, with: "person.\(property)")
        }
        
        // Remplacer les opérateurs NSPredicate par Swift
        converted = converted.replacingOccurrences(of: " AND ", with: " && ")
        converted = converted.replacingOccurrences(of: " OR ", with: " || ")
        converted = converted.replacingOccurrences(of: " NOT ", with: " !")
        converted = converted.replacingOccurrences(of: "BEGINSWITH", with: "hasPrefix")
        converted = converted.replacingOccurrences(of: "ENDSWITH", with: "hasSuffix")
        converted = converted.replacingOccurrences(of: "CONTAINS", with: "contains")
        
        return "#Predicate<EntityPerson> { person in\n    \(converted)\n}"
    }


}
