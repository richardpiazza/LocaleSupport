import LocaleSupport
import Foundation
import Statement

public struct Expression: Identifiable {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case defaultLanguage = "default_language"
        case comment
        case feature
        case translations
    }
    
    public enum Query {
        case id(_ id: Expression.ID)
        case name(_ name: String)
    }
    
    public enum Update {
        case name(_ name: String)
        case defaultLanguage(_ language: LanguageCode)
        case comment(_ comment: String?)
        case feature(_ feature: String?)
    }
    
    internal var schema: Schema {
        return Schema(
            name: "expression",
            columns: [_id, _name, _defaultLanguage, _comment, _feature]
        )
    }
    
    /// Unique/Primary Key
    @Column(key: .id, notNull: true, unique: true, primaryKey: true, autoIncrement: true)
    public var id: Int = 0
    
    /// Key that identifies a collection of translations.
    @Column(key: .name, notNull: true)
    public var name: String = ""
    
    /// The `languageCode` raw value.
    @Column(key: .defaultLanguage, notNull: true)
    public var defaultLanguage: String = LanguageCode.default.rawValue
    
    /// Contextual information that guides translators.
    @Column(key: .comment)
    public var comment: String? = nil
    
    /// Optional grouping identifier.
    @Column(key: .feature)
    public var feature: String? = nil
    
    /// Associated translations.
    public var translations: [Translation] = []
    
    /// The default/development language code.
    public var languageCode: LanguageCode {
        get { LanguageCode(rawValue: defaultLanguage) ?? .default }
        set { defaultLanguage = newValue.rawValue }
    }
    
    public init(
        name: String,
        languageCode: LanguageCode = .default,
        comment: String? = nil,
        feature: String? = nil,
        translations: [Translation] = []
    ) {
        id = -1
        self.name = name
        self.defaultLanguage = languageCode.rawValue
        self.comment = comment
        self.feature = feature
        self.translations = translations
    }
    
    internal init(
        id: ID,
        name: String,
        defaultLanguage: String,
        comment: String?,
        feature: String?,
        translations: [Translation]
    ) {
        self.id = id
        self.name = name
        self.defaultLanguage = defaultLanguage
        self.comment = comment
        self.feature = feature
        self.translations = translations
    }
    
    internal init(
        id: ID,
        name: String,
        languageCode: LanguageCode,
        comment: String?,
        feature: String?,
        translations: [Translation]
    ) {
        self.id = id
        self.name = name
        self.defaultLanguage = languageCode.rawValue
        self.comment = comment
        self.feature = feature
        self.translations = translations
    }
    
    internal init() {}
}

extension Expression: Table {
    public static var schema: Schema = { Expression().schema }()
}

extension Expression {
    static var id: AnyColumn = { schema[.id] }()
    static var name: AnyColumn = { schema[.name] }()
    static var defaultLanguage: AnyColumn = { schema[.defaultLanguage] }()
    static var comment: AnyColumn = { schema[.comment] }()
    static var feature: AnyColumn = { schema[.feature] }()
}

private extension Schema {
    subscript(codingKey: Expression.CodingKeys) -> AnyColumn {
        guard let column = columns.first(where: { $0.name == codingKey.stringValue }) else {
            preconditionFailure("Invalid column name '\(codingKey.stringValue)'.")
        }
        
        return column
    }
}

private extension Column {
    init(
        wrappedValue: T,
        key: Expression.CodingKeys,
        notNull: Bool = false,
        unique: Bool = false,
        provideDefault: Bool = false,
        primaryKey: Bool = false,
        autoIncrement: Bool = false,
        foreignKey: AnyColumn? = nil
    ) {
        let dataType: String
        
        switch T.self {
        case is Int.Type:
            dataType = "INTEGER"
        default:
            dataType = "TEXT"
        }
        
        self.init(
            wrappedValue: wrappedValue,
            table: Expression.self,
            name: key.stringValue,
            dataType: dataType,
            notNull: notNull,
            unique: unique,
            provideDefault: provideDefault,
            primaryKey: primaryKey,
            autoIncrement: autoIncrement,
            foreignKey: foreignKey
        )
    }
}
