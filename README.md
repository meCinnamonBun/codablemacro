# CodableMacroPackage

CodableMacroPackage is number of macros which helps to generate CodingKeys without lots of boilerplate code

## Macros

1. `CodableKey(key: String)` - mark the property you need to be Codable with name `key`
2. `UncodableKey()` - mark the property you don't need to be Codable
3. `CodableBlock()` - the main macro. You should mark object which needs to have CodingKeys

## Important
- If the name of variable is the same as key there is no need to add `CodableKey`
- Computed properties are ignored by default

## Example

The code below:

```swift
@CodableBlock
struct A {

    @CodableKey("some_name")
    let name: String
    @CodableKey("myFavouriteBool")
    let bool: Bool

    let number: Int

    @UncodableKey
    var numberOfShows: Int

    var computeStr: String {
        return ""
    }

}
```

generates this CodingKeys:
```swift
enum CodingKeys: String, CodingKey {
    case name = "some_name"
    case bool = "myFavouriteBool"
    case number
}
```
