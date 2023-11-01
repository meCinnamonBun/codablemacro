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

    @CodableKey("computeStr")
    var computeStr: String {
        return "Some text with \(number)"
    }

}

extension A {

    init(name: String, bool: Bool, number: Int) {
        self.name = name
        self.bool = bool
        self.number = number
    }

    init(name: String, bool: Bool, number: Int, numberOfShows: Int) {
        self.name = name
        self.bool = bool
        self.number = number
        self.numberOfShows = numberOfShows
    }

}

var a = A(name: "name", bool: false, number: 1, numberOfShows: 2)

let data = try JSONEncoder().encode(a)
let string = try JSONSerialization.jsonObject(with: data) as? [String: Any]

print(string)
