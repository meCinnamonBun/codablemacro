import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct CodableKeyMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }

}

public struct UncodableKeyMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }

}

public struct CodableBlockMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let enumCases = getEnumCases(for: declaration.memberBlock.members)

        guard !enumCases.isEmpty else {
            let errorDiagnose = Diagnostic(
                node: Syntax(node),
                message: MistakeDiagnostic.empty
            )

            context.diagnose(errorDiagnose)

            return []
        }

        let enumSyntax = try generateCodingKeys(by: enumCases)

        return [DeclSyntax(enumSyntax)]
    }

    private static func getEnumCases(for members: MemberBlockItemListSyntax) -> [(String, String?)] {
        members.compactMap { member -> (String, String?)? in
            let decl = member.decl.as(VariableDeclSyntax.self)

            guard let variableName = decl?.bindings.first?.pattern
                .as(IdentifierPatternSyntax.self)?.identifier.text else {
                return nil
            }

            guard let attribute = decl?.attributes.first?
                .as(AttributeSyntax.self),
               let attributeName = attribute.attributeName
                .as(IdentifierTypeSyntax.self)?.name.text else {
                // ignores computed property
                guard !(decl?.bindings
                    .as(PatternBindingListSyntax.self)?.first?.accessorBlock?.accessors
                    .is(CodeBlockItemListSyntax.self) ?? false) else {
                    return nil
                }
                return (variableName, nil)
            }

            if attributeName == "CodableKey",
               let variableCodableName = attribute.arguments?
                .as(LabeledExprListSyntax.self)?.first?.expression
                .as(StringLiteralExprSyntax.self)?.segments.first?
                .as(StringSegmentSyntax.self)?.content.text {

                return variableName != variableCodableName
                ? (variableName, variableCodableName)
                : (variableName, nil)
            } else if attributeName == "UncodableKey" {
                return nil
            } else {
                return (variableName, nil)
            }
        }
    }

    private static func generateCodingKeys(by enumCases: [(String, String?)]) throws -> EnumDeclSyntax {
        try EnumDeclSyntax("enum CodingKeys: String, CodingKey", membersBuilder: {
            let stringCases = enumCases.map { name, codingName in
                guard let codingName else { return "\(Keyword.case) \(name)" }
                return "\(Keyword.case) \(name) = \"\(codingName)\""
            }
            for stringCase in stringCases {
                try EnumCaseDeclSyntax("\(raw: stringCase)")
            }
        })
    }

}

private extension CodableBlockMacro {

    enum MistakeDiagnostic: String {
        case empty
    }
}

extension CodableBlockMacro.MistakeDiagnostic: DiagnosticMessage {

    var message: String {
        switch self {
        case .empty:
            return  "No codable cases found"
        }
    }

    var diagnosticID: MessageID {
        .init(domain: "CodeableMacros", id: rawValue)
    }

    var severity: DiagnosticSeverity {

        switch self {
        case .empty:
            return .warning
        }
    }

}

@main
struct TestMacroPackagePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CodableKeyMacro.self,
        UncodableKeyMacro.self,
        CodableBlockMacro.self
    ]
}

