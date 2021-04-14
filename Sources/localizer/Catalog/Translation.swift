import LocaleSupport
import Foundation
import Statement

public struct Translation: Identifiable {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case expressionID = "expression_id"
        case language = "language_code"
        case script = "script_code"
        case region = "region_code"
        case value
    }
    
    public enum Update {
        case expressionID(_ id: Expression.ID)
        case language(_ language: LanguageCode)
        case script(_ script: ScriptCode?)
        case region(_ region: RegionCode?)
        case value(_ value: String)
    }
    
    internal var schema: Schema {
        return Schema(
            name: "translation",
            columns: [_id, _expressionID, _language, _script, _region, _value]
        )
    }
    
    /// Unique/Primary Key
    @Column(key: .id, notNull: true, unique: true, primaryKey: true, autoIncrement: true)
    public var id: Int = 0
    
    /// Expression (Foreign Key)
    @Column(key: .expressionID, notNull: true, foreignKey: Expression.id)
    public var expressionID: Expression.ID = 0
    
    /// Language of the translation
    @Column(key: .language, notNull: true)
    public var language: String = LanguageCode.default.rawValue
    
    /// Script code specifier
    @Column(key: .script)
    public var script: String? = nil
    
    /// Region code specifier
    @Column(key: .region)
    public var region: String? = nil
    
    /// The translated string
    @Column(key: .value, notNull: true)
    public var value: String = ""
    
    public init(expressionID: Expression.ID, language: LanguageCode = .default, script: ScriptCode? = nil, region: RegionCode? = nil, value: String) {
        id = -1
        self.expressionID = expressionID
        self.language = language.rawValue
        self.script = script?.rawValue
        self.region = region?.rawValue
        self.value = value
    }
    
    internal init(id: ID, expressionID: Expression.ID, language: String, script: String?, region: String?, value: String) {
        self.id = id
        self.expressionID = expressionID
        self.language = language
        self.script = script
        self.region = region
        self.value = value
    }
    
    internal init(id: ID, expressionID: Expression.ID, languageCode: LanguageCode, scriptCode: ScriptCode?, regionCode: RegionCode?, value: String) {
        self.id = id
        self.expressionID = expressionID
        self.language = languageCode.rawValue
        self.script = scriptCode?.rawValue
        self.region = regionCode?.rawValue
        self.value = value
    }
    
    internal init() { }
}

public extension Translation {
    var languageCode: LanguageCode {
        get { LanguageCode(rawValue: language) ?? .en }
        set { language = newValue.rawValue }
    }
    
    var scriptCode: ScriptCode? {
        get { (script != nil) ? ScriptCode(rawValue: script!) : nil }
        set { script = newValue?.rawValue }
    }
    
    var regionCode: RegionCode? {
        get { (region != nil) ? RegionCode(rawValue: region!) : nil }
        set { region = newValue?.rawValue }
    }
    
    var designator: String {
        var output = languageCode.rawValue
        if let scriptCode = script {
            output += "-\(scriptCode)"
        }
        if let regionCode = region {
            output += "_\(regionCode)"
        }
        return output
    }
}

extension Translation: Table {
    public static var schema: Schema = { Translation().schema }()
}

extension Translation {
    static var id: AnyColumn = { schema[.id] }()
    static var expressionID: AnyColumn = { schema[.expressionID] }()
    static var language: AnyColumn = { schema[.language] }()
    static var script: AnyColumn = { schema[.script] }()
    static var region: AnyColumn = { schema[.region] }()
    static var value: AnyColumn = { schema[.value] }()
}

private extension Schema {
    subscript(codingKey: Translation.CodingKeys) -> AnyColumn {
        guard let column = columns.first(where: { $0.name == codingKey.stringValue }) else {
            preconditionFailure("Invalid column name '\(codingKey.stringValue)'.")
        }
        
        return column
    }
}

private extension Column {
    init(
        wrappedValue: T,
        key: Translation.CodingKeys,
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
            table: Translation.self,
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
