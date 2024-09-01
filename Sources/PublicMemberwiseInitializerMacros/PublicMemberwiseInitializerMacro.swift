import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


public struct PublicMemberwiseInitializerMacro: MemberMacro {
    enum PublicMemberwiseInitializerMacroError: Error {
        case unsupportedType
        case unsupportedTypeAnnotation
    }
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
            guard declaration.as(StructDeclSyntax.self) != nil else {
                throw PublicMemberwiseInitializerMacroError.unsupportedType
            }
            let variableDeclarations = declaration.memberBlock.members.compactMap({ $0.decl.as(VariableDeclSyntax.self) })
            let rows = try variableDeclarations.flatMap { declaration in
                try (declaration.bindings.as(PatternBindingListSyntax.self)?.compactMap { patternBinding -> (IdentifierPatternSyntax, TypeSyntax?)? in
                            guard patternBinding.accessorBlock == nil && patternBinding.initializer == nil else {
                                return nil // Ignore computed properties
                            }
                            if let identifier = patternBinding.pattern.as(IdentifierPatternSyntax.self) {
                                // Get the type, if available
                                return (identifier, patternBinding.typeAnnotation?.type)
                            }
                            return nil
                        } ?? []
                    )
                    .reversed()
                    // Backfill any ommited types
                    .reduce([(IdentifierPatternSyntax, TypeSyntax)]()) { partialResult, identifierAndTypeAnnotation in
                        var partialResult = partialResult
                        guard let typeAnnotation = identifierAndTypeAnnotation.1 ?? partialResult.last?.1 else {
                            throw PublicMemberwiseInitializerMacroError.unsupportedTypeAnnotation
                        }
                        partialResult.append((identifierAndTypeAnnotation.0, typeAnnotation))
                        return partialResult
                    }
                    .reversed()

            }
            guard !rows.isEmpty else {
                return [
                    """
                    public init(){}
                    """
                ]
            }
            let initParams = try rows.map { (identifier, type) in
                let typeString = try getTypeAsString(type: type)
                return "\(identifier.identifier.text): \(typeString)"
            }
            .joined(separator: ",\n")
            let initAssignments = rows.map { (identifier, type) in
                    "self.\(identifier.identifier.text) = \(identifier.identifier.text)"
                }
                .joined(separator: "\n")
            return [
                """
                public init(
                    \(raw: initParams)
                ) {
                    \(raw: initAssignments)
                }
                """
            ]
    }
    private static func getTypeAsString(type: TypeSyntax) throws -> String {
        if let identifierType = type.as(IdentifierTypeSyntax.self) {
            return identifierType.name.text
        }
        if let optionalType = type.as(OptionalTypeSyntax.self) {
            return "\(try getTypeAsString(type: optionalType.wrappedType))?"
        }
        if let arrayLiteralType = type.as(ArrayTypeSyntax.self) {
            return "[\(try getTypeAsString(type: arrayLiteralType.element))]"
        }
        if let dictLiteralType = type.as(DictionaryTypeSyntax.self) {
            return "[\(try getTypeAsString(type: dictLiteralType.key)): \(try getTypeAsString(type: dictLiteralType.value))]"
        }
        throw PublicMemberwiseInitializerMacroError.unsupportedTypeAnnotation
    }
}

@main
struct PublicMemberwiseInitializerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PublicMemberwiseInitializerMacro.self,
    ]
}
