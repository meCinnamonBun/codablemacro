import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(CodableMacroPackageMacros)
import CodableMacroPackageMacros

let testCodabelMacros: [String: Macro.Type] = [
    "CodableBlock": CodableBlockMacro.self
]
#endif

final class TestMacroPackageTests: XCTestCase {

    func testCodableMacroOne() throws {
        #if canImport(CodableMacroPackageMacros)
        assertMacroExpansion(
            """
            @CodableBlock
            struct Entity {
                let number: Int
            }
            """,
            expandedSource: """
            struct Entity {
                let number: Int

                enum CodingKeys: String, CodingKey {
                    case number
                }
            }
            """,
            macros: testCodabelMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodableMacroName() throws {
        #if canImport(CodableMacroPackageMacros)
        assertMacroExpansion(
            """
            @CodableBlock
            struct Entity {
                @CodableKey("some_name")
                let someName: String
            }
            """,
            expandedSource: """
            struct Entity {
                @CodableKey("some_name")
                let someName: String

                enum CodingKeys: String, CodingKey {
                    case someName = "some_name"
                }
            }
            """,
            macros: testCodabelMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodableMacroUncode() throws {
        #if canImport(CodableMacroPackageMacros)
        assertMacroExpansion(
            """
            @CodableBlock
            struct Entity {
                let number: Int
                @UncodableKey()
                let count: Int
            }
            """,
            expandedSource: """
            struct Entity {
                let number: Int
                @UncodableKey()
                let count: Int

                enum CodingKeys: String, CodingKey {
                    case number
                }
            }
            """,
            macros: testCodabelMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testCodableMacroFull() throws {
        #if canImport(CodableMacroPackageMacros)
        assertMacroExpansion(
            """
            @CodableBlock
            struct Entity {

                @CodableKey("some_name")
                let someName: String
                let number: Int

                @UncodableKey()
                let count: Int

                var tt: String {
                    return ""
                }

                var ttt: String = "" {
                    didSet {
                        print(ttt)
                    }
                }

            }
            """,
            expandedSource: """
            struct Entity {

                @CodableKey("some_name")
                let someName: String
                let number: Int

                @UncodableKey()
                let count: Int

                var tt: String {
                    return ""
                }

                var ttt: String = "" {
                    didSet {
                        print(ttt)
                    }
                }

                enum CodingKeys: String, CodingKey {
                    case someName = "some_name"
                    case number
                    case ttt
                }

            }
            """,
            macros: testCodabelMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

}
