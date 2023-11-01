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

        var result: [DeclSyntax] = [DeclSyntax(enumSyntax)]

        let shouldGenerateInit = enumCases.contains(where: { $0.isComputed })
        if shouldGenerateInit {
            let initSyntax = try generateInit(by: enumCases)
            result.append(DeclSyntax(initSyntax))
        }

        return result
    }

    private static func getEnumCases(for members: MemberBlockItemListSyntax) -> [EnumCase] {
        members.compactMap { member -> EnumCase? in
            let decl = member.decl.as(VariableDeclSyntax.self)

            guard let variableName = decl?.bindings.first?.pattern
                .as(IdentifierPatternSyntax.self)?.identifier.text else {
                return nil
            }

            guard let binding = decl?.bindings
                .as(PatternBindingListSyntax.self)?.first else {
                return nil
            }

            let isComputed = binding.accessorBlock?.accessors
                .is(CodeBlockItemListSyntax.self) ?? false

            guard let variableType = binding.typeAnnotation?.type
                .as(IdentifierTypeSyntax.self)?.name.text else {
                return nil
            }

            var enumCase = EnumCase(
                variableName: variableName,
                variableCodableName: nil,
                variableType: variableType,
                isComputed: isComputed
            )

            guard let attribute = decl?.attributes.first?
                .as(AttributeSyntax.self),
               let attributeName = attribute.attributeName
                .as(IdentifierTypeSyntax.self)?.name.text else {
                // ignores computed property
                guard !isComputed else { return nil }
                return enumCase
            }

            if attributeName == "CodableKey",
               let variableCodableName = attribute.arguments?
                .as(LabeledExprListSyntax.self)?.first?.expression
                .as(StringLiteralExprSyntax.self)?.segments.first?
                .as(StringSegmentSyntax.self)?.content.text {

                if variableName != variableCodableName {
                    enumCase.variableCodableName = variableCodableName
                }
                return enumCase

            } else if attributeName == "UncodableKey" {
                return nil
            } else {
                return enumCase
            }
        }
    }

    private static func generateCodingKeys(by enumCases: [EnumCase]) throws -> EnumDeclSyntax {
        try EnumDeclSyntax("enum CodingKeys: String, CodingKey", membersBuilder: {
            let stringCases = enumCases.map { enumCase in
                guard let codingName = enumCase.variableCodableName else {
                    return "\(Keyword.case) \(enumCase.variableName)"
                }
                return "\(Keyword.case) \(enumCase.variableName) = \"\(codingName)\""
            }
            for stringCase in stringCases {
                try EnumCaseDeclSyntax("\(raw: stringCase)")
            }
        })
    }

    private static func generateInit(by enumCases: [EnumCase]) throws -> InitializerDeclSyntax {
        try InitializerDeclSyntax("init(from decoder: Decoder) throws") {
            let stringVariables = enumCases.compactMap { enumCase -> String? in
                guard !enumCase.isComputed else { return nil }
                return "\(enumCase.variableName) = try values.decode(\(enumCase.variableType).self, forKey: .\(enumCase.variableName))"
            }
            try VariableDeclSyntax("let values = try decoder.container(keyedBy: CodingKeys.self)")
            for stringVariable in stringVariables {
                ExprSyntax(stringLiteral: stringVariable)
            }
        }
    }

}

private extension CodableBlockMacro {

    enum MistakeDiagnostic: String {
        case empty
    }

    private struct EnumCase {
        let variableName: String
        var variableCodableName: String?
        let variableType: String
        let isComputed: Bool
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

