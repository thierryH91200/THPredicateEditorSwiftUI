import SwiftUI
import Combine
import AppKit

import SwiftData
import SwiftDate

// Make Person usable in SwiftUI Table rows
extension Person: Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
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

            Text(vm.predicate?.predicateFormat ?? String(localized:"No predicate"))
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            HStack {
                let t = vm.swiftDataPredicate(from: vm.predicate)
                Text(t?.description ?? "nil")
                Text(vm.swiftDataPredicate(from: vm.predicate) != nil ? "Parsed → OK" : "Parsed → nil")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Log Predicates") {
                    print("NSPredicate:", vm.predicate?.predicateFormat ?? "nil")
                    let parsed = vm.swiftDataPredicate(from: vm.predicate)
                    print("SwiftData Predicate:", parsed != nil ? "OK" : "nil")
                }
                .buttonStyle(.bordered)
            }

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

//            let t = vm.swiftDataPredicate(from: vm.predicate)
//            Text(String(reflecting: t))
            Text(vm.predicate?.predicateFormat ?? "Aucun prédicat")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            HStack {
                Text(vm.swiftDataPredicate(from: vm.predicate) != nil ? "Parsed → OK" : "Parsed → nil")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Log Predicates") {
                    print("NSPredicate:", vm.predicate?.predicateFormat ?? "nil")
                    let parsed = vm.swiftDataPredicate(from: vm.predicate)
                    print("SwiftData Predicate:", parsed != nil ? "OK" : "nil")
                }
                .buttonStyle(.bordered)
            }

            Table(vm.filteredData) {
                TableColumn("First Name") { Text($0.firstName) }
                TableColumn("Last Name") { Text($0.lastName) }
                TableColumn("Age") { Text("\($0.age)") }
                TableColumn("Country") { Text($0.country) }
                TableColumn("Department") { Text($0.department) }
                TableColumn("Bool") { Text($0.isBool ? "true" : "false") }
                TableColumn("Date of birth") {
                    Text($0.dateOfBirth.formatted(date: .abbreviated, time: .omitted))
                }
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

