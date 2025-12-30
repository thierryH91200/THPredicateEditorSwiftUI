import SwiftUI
import AppKit

struct PredicateEditorView: NSViewRepresentable {
    @Binding var predicate: NSPredicate?
    var rowTemplates: [NSPredicateEditorRowTemplate]

    func makeNSView(context: Context) -> NSPredicateEditor {
        let editor = NSPredicateEditor()

        if let path = Bundle.main.path(forResource: "Predicate", ofType: "strings"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            editor.formattingDictionary = dict
        }

        editor.rowTemplates = rowTemplates
        editor.objectValue = predicate

        editor.target = context.coordinator
        editor.action = #selector(Coordinator.changed(_:))
        return editor
    }

    func updateNSView(_ nsView: NSPredicateEditor, context: Context) {
        nsView.objectValue = predicate
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(predicate: $predicate)
    }

    final class Coordinator: NSObject {
        var predicate: Binding<NSPredicate?>
        init(predicate: Binding<NSPredicate?>) { self.predicate = predicate }
        @objc func changed(_ sender: NSPredicateEditor) {
            predicate.wrappedValue = sender.predicate
        }
    }
}

// MARK: - Helper to build default row templates similar to MainWindowController
extension PredicateEditorView {
    static func defaultRowTemplates() -> [NSPredicateEditorRowTemplate] {
        var templates: [NSPredicateEditorRowTemplate] = []

        // Compound
        let compound = NSPredicateEditorRowTemplate(compoundTypes: [.and, .or, .not])
        templates.append(compound)

        // String comparisons for firstName, lastName
        let stringOps: [NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo]
        templates.append(NSPredicateEditorRowTemplate(stringCompareForKeyPaths: ["firstName"], operators: stringOps))
        templates.append(NSPredicateEditorRowTemplate(stringCompareForKeyPaths: ["lastName"], operators: stringOps))

        // Int comparisons for age
        let intOps: [NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo, .greaterThan, .greaterThanOrEqualTo, .lessThan, .lessThanOrEqualTo]
        templates.append(NSPredicateEditorRowTemplate(IntCompareForKeyPaths: ["age"], operators: intOps))

        // Date comparisons for dateOfBirth
        let dateOps: [NSComparisonPredicate.Operator] = [.equalTo, .greaterThanOrEqualTo, .lessThanOrEqualTo, .greaterThan, .lessThan]
        templates.append(NSPredicateEditorRowTemplate(DateCompareForKeyPaths: ["dateOfBirth"], operators: dateOps))

        // Constant values for country
        let countryOps: [NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo]
        let countries = ["United States","Mexico", "Canada", "Brazil"]
        templates.append(NSPredicateEditorRowTemplate(forKeyPath: "country", withValues: countries, operators: countryOps))

        // Bool comparisons for isBool
        let boolOps: [NSComparisonPredicate.Operator] = [.equalTo, .notEqualTo]
        templates.append(NSPredicateEditorRowTemplate(BoolCompareForKeyPaths: ["isBool"], operators: boolOps))

        return templates
    }
}
