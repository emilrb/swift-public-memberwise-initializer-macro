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
                let someInt: Int, anotherInt: Int
                let a, b: String, c, d: Int
                let e = "String"
                let f: Int
            }
            """,
            expandedSource: """
            public struct MyStruct {
                let myCoolString: String
                let someInt: Int, anotherInt: Int
                let a, b: String, c, d: Int
                let e = "String"
                let f: Int

                public init(
                    myCoolString: String,
                    someInt: Int,
                    anotherInt: Int,
                    a: String,
                    b: String,
                    c: Int,
                    d: Int,
                    f: Int
                ) {
                    self.myCoolString = myCoolString
                    self.someInt = someInt
                    self.anotherInt = anotherInt
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
