import ArgumentParser
import Foundation

extension Catalog {
    struct Insert: ParsableCommand {
        static var configuration: CommandConfiguration = .init(
            commandName: "insert",
            abstract: "Adds a single entity to the catalog.",
            discussion: """
            
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [
                ExpressionEntity.self,
                TranslationEntity.self
            ],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
    }
}

extension Catalog.Insert {
    struct ExpressionEntity: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "expression",
            abstract: "Add an Expression to the catalog.",
            discussion: """
            
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Key that identifies a collection of translations.")
        var name: String
        
        @Option(help: "The default/development language code.")
        var defaultLanguage: LanguageCode = .default
        
        @Option(help: "Contextual information that guides translators.")
        var comment: String?
        
        @Option(help: "Optional grouping identifier.")
        var feature: String?
        
        @Option(help: "Overrides the default support directory path for the catalog database.")
        var catalogPath: String?
        
        func validate() throws {
            guard !name.isEmpty else {
                throw ValidationError("Must provide a non-empty 'name'.")
            }
        }
        
        func run() throws {
            let path = try catalogPath ?? FileManager.default.catalogURL().path
            let db = try SQLiteDatabase(path: path)
            
            let expression = Expression(name: name, defaultLanguage: defaultLanguage, comment: comment, feature: feature)
            let id = try db.insertExpression(expression)
            print("Inserted Expression [\(id)] '\(expression.name)'")
        }
    }
}

extension Catalog.Insert {
    struct TranslationEntity: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "translation",
            abstract: "Add a Translation to the catalog.",
            discussion: """
            
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "ID of the Expression to which this translation links.")
        var expression: Expression.ID
        
        @Argument(help: "Language of the translation.")
        var language: LanguageCode
        
        @Argument(help: "The translated string.")
        var value: String
        
        @Option(help: "Region code specifier.")
        var region: RegionCode?
        
        @Option(help: "Overrides the default support directory path for the catalog database.")
        var catalogPath: String?
        
        func run() throws {
            let path = try catalogPath ?? FileManager.default.catalogURL().path
            let db = try SQLiteDatabase(path: path)
            
            let translation = Translation(expressionID: expression, language: language, region: region, value: value)
            let id = try db.insertTranslation(translation)
            print("Inserted Translation [\(id)] '\(value)'")
        }
    }
}
