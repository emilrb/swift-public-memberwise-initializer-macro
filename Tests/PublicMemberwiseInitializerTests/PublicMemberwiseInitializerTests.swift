import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(PublicMemberwiseInitializerMacros)
import PublicMemberwiseInitializerMacros

let testMacros: [String: Macro.Type] = [
    "PublicMemberwiseInitializerMacro": PublicMemberwiseInitializerMacro.self,
]
#endif

final class PublicMemberwiseInitializerTests: XCTestCase {
    func testMacro() throws {
        #if canImport(PublicMemberwiseInitializerMacros)
        assertMacroExpansion(
            """
            @PublicMemberwiseInitializerMacro
            public struct MyStruct {
                let myCoolString: String
                let myOptionalString: String?
                let someInt: Int, anotherInt: Int
                let anArray: [String]
                let anOptionalArray: [String]?
                let anArrayOfOptionals: [String?]
                let anOptionalArrayOfOptionals: [String?]?
                let anArrayOfArrays: [[String]]
                let dict: [String: Double]
                let anOptional: Int?, anotherOptional: String?
                let a, b: String, c, d: Int
                let e = "String"
                let f: Int
            }
            """,
            expandedSource: """
            public struct MyStruct {
                let myCoolString: String
                let myOptionalString: String?
                let someInt: Int, anotherInt: Int
                let anArray: [String]
                let anOptionalArray: [String]?
                let anArrayOfOptionals: [String?]
                let anOptionalArrayOfOptionals: [String?]?
                let anArrayOfArrays: [[String]]
                let dict: [String: Double]
                let anOptional: Int?, anotherOptional: String?
                let a, b: String, c, d: Int
                let e = "String"
                let f: Int

                public init(
                    myCoolString: String,
                    myOptionalString: String?,
                    someInt: Int,
                    anotherInt: Int,
                    anArray: [String],
                    anOptionalArray: [String]?,
                    anArrayOfOptionals: [String?],
                    anOptionalArrayOfOptionals: [String?]?,
                    anArrayOfArrays: [[String]],
                    dict: [String: Double],
                    anOptional: Int?,
                    anotherOptional: String?,
                    a: String,
                    b: String,
                    c: Int,
                    d: Int,
                    f: Int
                ) {
                    self.myCoolString = myCoolString
                    self.myOptionalString = myOptionalString
                    self.someInt = someInt
                    self.anotherInt = anotherInt
                    self.anArray = anArray
                    self.anOptionalArray = anOptionalArray
                    self.anArrayOfOptionals = anArrayOfOptionals
                    self.anOptionalArrayOfOptionals = anOptionalArrayOfOptionals
                    self.anArrayOfArrays = anArrayOfArrays
                    self.dict = dict
                    self.anOptional = anOptional
                    self.anotherOptional = anotherOptional
                    self.a = a
                    self.b = b
                    self.c = c
                    self.d = d
                    self.f = f
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
