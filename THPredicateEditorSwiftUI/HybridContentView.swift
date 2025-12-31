import SwiftUI
import Combine
import AppKit

import SwiftData

// Make Person usable in SwiftUI Table rows
extension Person: Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
}


@MainActor
final class HybridViewModel: ObservableObject {
    @Published var people: [Person] = []
    @Published var person: [EntityPerson] = []
    @Published var predicate: NSPredicate? = nil
    
    var modelContext: ModelContext? {
        DataContext.shared.context
    }


    init() {
        seed()
        seedData()
        // Optionally apply a default predicate similar to MainWindowController
//        let defaultFormat = "firstName ==[cd] 'John' OR lastName ==[cd] 'doe' OR (dateOfBirth <= CAST('11/18/2018 00:00', 'NSDate') AND dateOfBirth >= CAST('01/01/2018', 'NSDate')) OR country ==[cd] 'United States' OR age = 25"
        let defaultFormat = "firstName ==[cd] 'John'"
        self.predicate = NSPredicate(format: defaultFormat)
    }

    func seed() {
        people = [
            Person(firstName: "John", lastName: "Doe", dateOfBirth: Date(), age: 24, department: "Finance", country: "Canada", isBool: true),
            Person(firstName: "Peter", lastName: "Martin", dateOfBirth: Date(), age: 25, department: "Sales", country: "Mexico", isBool: false),
            Person(firstName: "John", lastName: "Trump", dateOfBirth: Date(), age: 26, department: "Finance", country: "Brazil", isBool: true),
            Person(firstName: "Mary", lastName: "Doe", dateOfBirth: Date(), age: 27, department: "Finance", country: "United States", isBool: true),
            Person(firstName: "Leo", lastName: "Doe", dateOfBirth: Date(), age: 28, department: "Sales", country: "Mexico", isBool: false),
            Person(firstName: "John", lastName: "Doe", dateOfBirth: Date(), age: 29, department: "Finance", country: "United States", isBool: true),
            Person(firstName: "John", lastName: "Leo", dateOfBirth: Date(), age: 30, department: "Finance", country: "Brazil", isBool: false)
        ]
    }
    
    func seedData() {
        person = [
            EntityPerson(firstName: "John", lastName: "Doe", dateOfBirth: Date(), age: 24, department: "Finance", country: "Canada", isBool: true),
            EntityPerson(firstName: "Peter", lastName: "Martin", dateOfBirth: Date(), age: 25, department: "Sales", country: "Mexico", isBool: false),
            EntityPerson(firstName: "John", lastName: "Trump", dateOfBirth: Date(), age: 26, department: "Finance", country: "Brazil", isBool: true),
            EntityPerson(firstName: "Mary", lastName: "Doe", dateOfBirth: Date(), age: 27, department: "Finance", country: "United States", isBool: true),
            EntityPerson(firstName: "Leo", lastName: "Doe", dateOfBirth: Date(), age: 28, department: "Sales", country: "Mexico", isBool: false),
            EntityPerson(firstName: "John", lastName: "Doe", dateOfBirth: Date(), age: 29, department: "Finance", country: "United States", isBool: true),
            EntityPerson(firstName: "John", lastName: "Leo", dateOfBirth: Date(), age: 30, department: "Finance", country: "Brazil", isBool: false)
    ]
//        for pople in person {
////            modelContext?.insert(pople)
//        }
//        try PersonManager.shared.save()

    }
    func swiftDataPredicate(from ns: NSPredicate?) -> Predicate<EntityPerson>? {
        guard let ns else { return nil }

        let format = ns.predicateFormat

        if format.contains("firstName ==[cd]") {
            return #Predicate<EntityPerson> { person in
                person.firstName.localizedStandardContains("John")
            }
        }

        if format.contains("lastName ==[cd]") {
            return #Predicate<EntityPerson> { person in
                person.lastName.localizedStandardContains("Doe")
            }
        }

        return nil
    }
    
    func fetchFilteredData() -> [EntityPerson] {
        guard let modelContext else { return [] }

        let descriptor = FetchDescriptor<EntityPerson>(
            predicate: swiftDataPredicate(from: predicate),
            sortBy: [SortDescriptor(\.lastName)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Erreur fetch :", error)
            return []
        }
    }
    
    var filteredData: [EntityPerson] {
        fetchFilteredData()
    }

    var filtered: [Person] {
        guard let predicate else { return people }
        // Evaluate NSPredicate against KVC-compliant objects (Person is NSObject)
        return (people as NSArray).filtered(using: predicate) as? [Person] ?? people
    }
//    var filteredData: [EntityPerson] {
//        guard let predicate else { return person }
//        // Evaluate NSPredicate against KVC-compliant objects (Person is NSObject)
//        return (person as NSArray).filtered(using: predicate) as? [EntityPerson] ?? person
//    }
}

struct HybridContentView: View {
    @StateObject private var vm = HybridViewModel()

    var body: some View {
        VStack(spacing: 12) {
            // NSPredicateEditor embedded in SwiftUI
            PredicateEditorView(
                predicate: $vm.predicate,
                rowTemplates: PredicateEditorView.defaultRowTemplates()
            )
            .frame(minHeight: 220)

            Text(vm.predicate?.predicateFormat ?? "Aucun prédicat")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Table(vm.filtered) {
                TableColumn("First Name") { Text($0.firstName) }
                TableColumn("Last Name") { Text($0.lastName) }
                TableColumn("Age") { Text("\($0.age)") }
                TableColumn("Country") { Text($0.country) }
                TableColumn("Department") { Text($0.department) }
                TableColumn("Bool") { Text($0.isBool ? "true" : "false") }
            }
        }
        .padding()
    }
}

struct HybridContentData: View {
    @StateObject private var vm = HybridViewModel()

    var body: some View {
        VStack(spacing: 12) {
            // NSPredicateEditor embedded in SwiftUI
            PredicateEditorView(
                predicate: $vm.predicate,
                rowTemplates: PredicateEditorView.defaultRowTemplates()
            )
            .frame(minHeight: 220)

            Text(vm.predicate?.predicateFormat ?? "Aucun prédicat")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Table(vm.filteredData) {
                TableColumn("First Name") { Text($0.firstName) }
                TableColumn("Last Name") { Text($0.lastName) }
                TableColumn("Age") { Text("\($0.age)") }
                TableColumn("Country") { Text($0.country) }
                TableColumn("Department") { Text($0.department) }
                TableColumn("Bool") { Text($0.isBool ? "true" : "false") }
            }
        }
        .padding()
    }
}

struct HybridContentPanel: View {
    var body: some View {
        TabView {
            HybridContentView()
                .tabItem {
                    Label("Object", systemImage: "house")
                }
            
            HybridContentData()
                .tabItem {
                    Label("SwiftData", systemImage: "eurosign.bank.building")
                }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .layoutPriority(1) // Priorité élevée pour occuper tout l’espace disponible
    }

}

