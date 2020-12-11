import XMLCoder

public struct Resource: Decodable, DynamicNodeDecoding {
    enum CodingKeys: String, CodingKey {
        case name
        case value = ""
    }
    
    public var name: String
    public var value: String
    
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
        case CodingKeys.name:
            return .attribute
        case CodingKeys.value:
            return .element
        default:
            return .elementOrAttribute
        }
    }
}

public extension Resource {
    func key(with id: Key.ID, language: String, region: String? = nil) -> Key {
        return Key(
            id: id,
            name: name,
            values: [
                Value(id: -1, key: id, language: language, region: region, localization: value)
            ]
        )
    }
}
