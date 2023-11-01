
@attached(peer, names: suffixed(codable))
public macro CodableKey(_ key: String) = #externalMacro(module: "CodableMacroPackageMacros", type: "CodableKeyMacro")

@attached(peer, names: suffixed(uncodable))
public macro UncodableKey() = #externalMacro(module: "CodableMacroPackageMacros", type: "UncodableKeyMacro")

@attached(member, names: arbitrary)
public macro CodableBlock() = #externalMacro(module: "CodableMacroPackageMacros", type: "CodableBlockMacro")
