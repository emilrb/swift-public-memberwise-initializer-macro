import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


public struct PublicMemberwiseInitializerMacro: MemberMacro {
    enum PublicMemberwiseInitializerMacroError: Error {
        case unsupportedType
        case unsupportedVarTypeSyntax
        case missingTypeAnnotation
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
                try (declaration.bindings.as(PatternBindingListSyntax.self)?.compactMap { patternBinding -> (IdentifierPatternSyntax, TypeSyntaxProtocol?)? in
                            guard patternBinding.accessorBlock == nil && patternBinding.initializer == nil else {
                                return nil // Ignore computed properties
                            }

                            if let identifier = patternBinding.pattern.as(IdentifierPatternSyntax.self) {
                                // Get the type, if available
                                let typeAnnotation: TypeSyntaxProtocol? = patternBinding.typeAnnotation?.type.as(IdentifierTypeSyntax.self) ?? patternBinding.typeAnnotation?.type.as(OptionalTypeSyntax.self)
                                return (identifier, typeAnnotation)
                            }
                            return nil
                        } ?? []
                    )
                    .reversed()
                    // Backfill any ommited types
                    .reduce([(IdentifierPatternSyntax, TypeSyntaxProtocol)]()) { partialResult, identifierAndTypeAnnotation in
                        var partialResult = partialResult
                        guard let typeAnnotation = identifierAndTypeAnnotation.1 ?? partialResult.last?.1 else {
                            throw PublicMemberwiseInitializerMacroError.missingTypeAnnotation
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
                let typeString: String
                if let identifierType = type.as(IdentifierTypeSyntax.self)?.name {
                    typeString = identifierType.text
                } else if let optionalTypeSyntax = type.as(OptionalTypeSyntax.self),
                          let identifierType = optionalTypeSyntax.wrappedType.as(IdentifierTypeSyntax.self)?.name {
                    typeString = "\(identifierType.text)?"
                } else {
                    throw PublicMemberwiseInitializerMacroError.unsupportedVarTypeSyntax
                }
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
}

@main
struct PublicMemberwiseInitializerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PublicMemberwiseInitializerMacro.self,
    ]
}
