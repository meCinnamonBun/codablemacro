# CodableMacroPackage

CodableMacroPackage is number of macros which helps to generate CodingKeys without lots of boilerplate code

## Macros

1. `CodableKey(key: String)` - mark the property you need to be Codable with name `key`
2. `UncodableKey()` - mark the property you don't need to be Codable
3. `CodableBlock()` - the main macro. You should mark object which needs to have CodingKeys

## Important
- If the name of variable is the same as key there is no need to add `CodableKey`
- Computed properties are ignored by default. You can use `CodableKey(key: String)` on it. Macros will generate `init(from decoder: Decoder)` and `func encode(to encoder: Encoder)`.

## Example

### 1

The code below:

```swift
@CodableBlock
struct A: Codable {

    @CodableKey("some_name")
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
```

generates this `CodingKeys`:

```swift
enum CodingKeys: String, CodingKey {
    case name = "some_name"
    case bool = "myFavouriteBool"
    case number
}
```

### 2

The code below:

```swift
@CodableBlock
struct B: Codable {

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
```

generates this `CodingKeys`, `init(from decoder: Decoder)` and `func encode(to encoder: Encoder)`:

```swift
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

func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(bool, forKey: .bool)
    try container.encode(number, forKey: .number)
    try container.encode(computeStr, forKey: .computeStr)
}
```
