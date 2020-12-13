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
    func expression(
        id: Expression.ID,
        defaultLanguage: LanguageCode = .en,
        comment: String? = nil,
        feature: String? = nil,
        language: LanguageCode,
        region: RegionCode? = nil
    ) -> Expression {
        return Expression(
            id: id,
            name: name,
            defaultLanguage: defaultLanguage,
            comment: comment,
            feature: feature,
            translations: [
                Translation(id: -1, expressionID: id, language: language, region: region, value: value)
            ]
        )
    }
}
