import CodableMacroPackage
import Foundation

@CodableBlock
struct A: Codable {

    @CodableKey("name")
    let name: String

    @CodableKey("myFavouriteBool")
    let bool: Bool

    let number: Int

    @UncodableKey
    var numberOfShows: Int = .zero

    var computeStr: String {
        return ""
    }

}

var a = A(name: "name", bool: false, number: 1, numberOfShows: 2)

let data = try JSONEncoder().encode(a)
let string = try JSONSerialization.jsonObject(with: data) as? [String: Any]

print(string)
