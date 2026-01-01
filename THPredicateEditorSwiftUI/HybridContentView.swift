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
        person = PersonManager.shared.getAllData()
        if person.isEmpty {
            seedData()
        }
        // Optionally apply a default predicate similar to MainWindowController
//        let defaultFormat = "firstName ==[cd] 'John' OR lastName ==[cd] 'doe' OR (dateOfBirth <= CAST('11/18/2018 00:00', 'NSDate') AND dateOfBirth >= CAST('01/01/2018', 'NSDate')) OR country ==[cd] 'United States' OR age = 25"
        let defaultFormat = "firstName == \"John\"" // OR lastName ==[cd] 'doe'"
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
        for p in person {
            modelContext?.insert(p)
        }
        try? PersonManager.shared.save()
    }
    
    // MARK: - Predicate parsing helpers
    private func trimOuterParens(_ s: String) -> String {
        var s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("(") && s.hasSuffix(")") {
            var level = 0
            var isBalanced = true
            for (i, ch) in s.enumerated() {
                if ch == "(" { level += 1 }
                else if ch == ")" { level -= 1; if level < 0 { isBalanced = false; break } }
                if i < s.count - 1 && level == 0 && i != s.count - 1 { isBalanced = false; break }
            }
            if isBalanced {
                s = String(s.dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return s
    }

    private enum Token { case expr(String); case and; case or }

    private func tokenizeTopLevel(_ s: String) -> [Token] {
        var tokens: [Token] = []
        var current = ""
        var level = 0
        var i = s.startIndex
        func flush() {
            let part = current.trimmingCharacters(in: .whitespacesAndNewlines)
            if !part.isEmpty { tokens.append(.expr(part)) }
            current = ""
        }
        while i < s.endIndex {
            let ch = s[i]
            if ch == "(" { level += 1; current.append(ch); i = s.index(after: i); continue }
            if ch == ")" { level -= 1; current.append(ch); i = s.index(after: i); continue }
            if level == 0 {
                if s[i...].hasPrefix(" AND ") {
                    flush(); tokens.append(.and); i = s.index(i, offsetBy: 5); continue
                }
                if s[i...].hasPrefix(" OR ") {
                    flush(); tokens.append(.or); i = s.index(i, offsetBy: 4); continue
                }
            }
            current.append(ch)
            i = s.index(after: i)
        }
        flush()
        return tokens
    }

    // Value parsing helpers
    private func parseBool(_ s: String) -> Bool? {
        let lower = s.lowercased()
        if ["true", "yes", "1"].contains(lower) { return true }
        if ["false", "no", "0"].contains(lower) { return false }
        return nil
    }

    private enum ParsedValue { case string(String), int(Int), bool(Bool) }

    private func parseValue(for key: String, from rhs: String) -> ParsedValue? {
        switch key {
        case "firstName", "lastName", "country", "department":
            return .string(rhs)
        case "age":
            if let v = Int(rhs) { return .int(v) }
        case "isBool":
            if let v = parseBool(rhs) { return .bool(v) }
        default:
            break
        }
        return nil
    }

    // Builders per type
    private func predicateForString(key: String, op: String, value: String) -> Predicate<EntityPerson>? {
        switch key {
        case "firstName":
            switch op { case "==": return #Predicate { $0.firstName == value }; case "!=": return #Predicate { $0.firstName != value }; default: return nil }
        case "lastName":
            switch op { case "==": return #Predicate { $0.lastName == value }; case "!=": return #Predicate { $0.lastName != value }; default: return nil }
        case "country":
            switch op { case "==": return #Predicate { $0.country == value }; case "!=": return #Predicate { $0.country != value }; default: return nil }
        case "department":
            switch op { case "==": return #Predicate { $0.department == value }; case "!=": return #Predicate { $0.department != value }; default: return nil }
        default:
            return nil
        }
    }

    private func predicateForInt(key: String, op: String, value: Int) -> Predicate<EntityPerson>? {
        switch key {
        case "age":
            switch op {
            case "==": return #Predicate { $0.age == value }
            case "!=": return #Predicate { $0.age != value }
            case ">":  return #Predicate { $0.age > value }
            case ">=": return #Predicate { $0.age >= value }
            case "<":  return #Predicate { $0.age < value }
            case "<=": return #Predicate { $0.age <= value }
            default: return nil
            }
        default:
            return nil
        }
    }

    private func predicateForBool(key: String, op: String, value: Bool) -> Predicate<EntityPerson>? {
        switch key {
        case "isBool":
            switch op { case "==": return #Predicate { $0.isBool == value }; case "!=": return #Predicate { $0.isBool != value }; default: return nil }
        default:
            return nil
        }
    }

    private func predicateForBinary(_ expr: String) -> Predicate<EntityPerson>? {
        let s = trimOuterParens(expr)
        let ops = [">=", "<=", "==", "!=", ">", "<"]
        var lhs = ""
        var op = ""
        var rhs = ""
        for candidate in ops {
            if let range = s.range(of: " " + candidate + " ") {
                lhs = String(s[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
                op = candidate
                rhs = String(s[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                break
            }
        }
        guard !lhs.isEmpty, !op.isEmpty, !rhs.isEmpty else { return nil }
        var cleanedRHS = rhs.trimmingCharacters(in: CharacterSet(charactersIn: "() "))
        if (cleanedRHS.hasPrefix("'") && cleanedRHS.hasSuffix("'")) || (cleanedRHS.hasPrefix("\"") && cleanedRHS.hasSuffix("\"")) {
            cleanedRHS = String(cleanedRHS.dropFirst().dropLast())
        }
        guard let parsed = parseValue(for: lhs, from: cleanedRHS) else { return nil }
        switch parsed {
        case .string(let v): return predicateForString(key: lhs, op: op, value: v)
        case .int(let v):    return predicateForInt(key: lhs, op: op, value: v)
        case .bool(let v):   return predicateForBool(key: lhs, op: op, value: v)
        }
    }
    
    func swiftDataPredicate(from ns: NSPredicate?) -> Predicate<EntityPerson>? {
        guard let ns else { return nil }

        // Normalize and parse the predicateFormat, supporting simple AND/OR combinations
        let raw = ns.predicateFormat
        // 1) Normalize operators with [cd] and trim
        var format = raw
            .replacingOccurrences(of: "==[cd]", with: "==")
            .replacingOccurrences(of: "!=[cd]", with: "!=")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        format = trimOuterParens(format)

        // Tokenize top-level AND/OR
        let tokens = tokenizeTopLevel(format)
        // If only one expression, return directly
        if tokens.count == 1, case let .expr(expr) = tokens[0] {
            return predicateForBinary(expr)
        }

        // Fold tokens left-to-right with AND/OR
        var currentPredicate: Predicate<EntityPerson>? = nil
        var pendingOp: Token? = nil
        for token in tokens {
            switch token {
            case .expr(let expr):
                guard let next = predicateForBinary(expr) else { return nil }
                if let pending = pendingOp, let existing = currentPredicate {
                    switch pending {
                    case .and:
                        currentPredicate = #Predicate<EntityPerson> { entity in
                            existing.evaluate(entity) && next.evaluate(entity)
                        }
                    case .or:
                        currentPredicate = #Predicate<EntityPerson> { entity in
                            existing.evaluate(entity) || next.evaluate(entity)
                        }
                    default:
                        break
                    }
                    pendingOp = nil
                } else {
                    currentPredicate = next
                }
            case .and, .or:
                pendingOp = token
            }
        }

        return currentPredicate
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
            HybridContentData()
                .tabItem {
                    Label("SwiftData", systemImage: "eurosign.bank.building")
                }

            HybridContentView()
                .tabItem {
                    Label("Object", systemImage: "house")
                }
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .layoutPriority(1) // Priorité élevée pour occuper tout l’espace disponible
    }

}

