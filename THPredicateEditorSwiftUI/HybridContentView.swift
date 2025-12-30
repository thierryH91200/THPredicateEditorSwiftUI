import SwiftUI
import Combine
import AppKit

// Make Person usable in SwiftUI Table rows
extension Person: Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
}


@MainActor
final class HybridViewModel: ObservableObject {
    @Published var people: [Person] = []
    @Published var predicate: NSPredicate? = nil

    init() {
        seed()
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

    var filtered: [Person] {
        guard let predicate else { return people }
        // Evaluate NSPredicate against KVC-compliant objects (Person is NSObject)
        return (people as NSArray).filtered(using: predicate) as? [Person] ?? people
    }
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
