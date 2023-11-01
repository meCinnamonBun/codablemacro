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

    func testCodableMacroAddComputed() throws {
        #if canImport(CodableMacroPackageMacros)
        assertMacroExpansion(
            """
            @CodableBlock
            struct A: Codable {

                @CodableKey("name")
                let name: String

                @CodableKey("myFavouriteBool")
                let bool: Bool

                let number: Int

                @UncodableKey
                var numberOfShows: Int = .zero

                @CodableKey("computeStr")
                var computeStr: String {
                    return ""
                }

            }
            """,
            expandedSource: """
            struct A: Codable {

                @CodableKey("name")
                let name: String

                @CodableKey("myFavouriteBool")
                let bool: Bool

                let number: Int

                @UncodableKey
                var numberOfShows: Int = .zero

                @CodableKey("computeStr")
                var computeStr: String {
                    return ""
                }

                enum CodingKeys: String, CodingKey {
                    case name
                    case bool = "myFavouriteBool"
                    case number
                    case computeStr
                }

                init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: CodingKeys.self)
                    name = try values.decode(String.self, forKey: .name)
                    bool = try values.decode(Bool.self, forKey: .bool)
                    number = try values.decode(Int.self, forKey: .number)
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
