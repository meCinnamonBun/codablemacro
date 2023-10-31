import CodableMacroPackage

@CodableBlock
struct A {

    @CodableKey("some_name")
    let name: String

    @CodableKey("myFavouriteBool")
    let t: Bool

    let number: Int

    @UncodableKey
    var numberOfShows: Int

    var computeStr: String {
        return ""
    }

}
