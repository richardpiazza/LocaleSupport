import ArgumentParser
import Foundation

extension Catalog {
    struct Update: ParsableCommand {
        static var configuration: CommandConfiguration = .init(
            commandName: "update",
            abstract: "Update a single entity in the catalog.",
            discussion: "",
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

extension Catalog.Update {
    struct ExpressionEntity: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "expression",
            abstract: "Update an Expression in the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Expression.")
        var id: Expression.ID
        
        @Option(help: "Key that identifies a collection of translations.")
        var name: String?
        
        @Option(help: "The default/development language code.")
        var defaultLanguage: LanguageCode?
        
        @Option(help: "Contextual information that guides translators.")
        var comment: String?
        
        @Option(help: "Optional grouping identifier.")
        var feature: String?
        
        @Option(help: "Overrides the default support directory path for the catalog database.")
        var catalogPath: String?
        
        func validate() throws {
            if let name = self.name {
                guard !name.isEmpty else {
                    throw ValidationError("Must provide a non-empty 'name'.")
                }
            }
        }
        
        func run() throws {
            let path = try catalogPath ?? FileManager.default.catalogURL().path
            let db = try SQLiteDatabase(path: path)
            
            guard let _ = try? db.expression(id) else {
                print("No Expression found with id '\(id)'.")
                return
            }
            
            if let name = self.name {
                try db.updateExpression(id, .name(name))
            }
            
            if let defaultLanguage = self.defaultLanguage {
                try db.updateExpression(id, .defaultLanguage(defaultLanguage))
            }
            
            if let comment = self.comment {
                let value = (comment.isEmpty) ? nil : comment
                try db.updateExpression(id, .comment(value))
            }
            
            if let feature = self.feature {
                let value = (feature.isEmpty) ? nil : feature
                try db.updateExpression(id, .feature(value))
            }
        }
    }
}

extension Catalog.Update {
    struct TranslationEntity: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "translation",
            abstract: "Update a Translation in the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Translation.")
        var id: Translation.ID
        
        @Option(help: "ID of the Expression to which this translation links.")
        var expression: Expression.ID?
        
        @Option(help: "Language of the translation.")
        var language: LanguageCode?
        
        @Option(help: "Region code specifier.")
        var region: RegionCode?
        
        @Option(help: "The translated string.")
        var value: String?
        
        @Flag(help: "Remove the region specifier from the translation.")
        var dropRegion: Bool = false
        
        @Option(help: "Overrides the default support directory path for the catalog database.")
        var catalogPath: String?
        
        func run() throws {
            let path = try catalogPath ?? FileManager.default.catalogURL().path
            let db = try SQLiteDatabase(path: path)
            
            guard let _ = try? db.translation(id) else {
                print("No Translation found with id '\(id)'.")
                return
            }
            
            if let expressionID = expression {
                try db.updateTranslation(id, .expressionID(expressionID))
            }
            
            if let language = self.language {
                try db.updateTranslation(id, .language(language))
            }
            
            if let region = self.region {
                try db.updateTranslation(id, .region(region))
            }
            
            if let value = self.value {
                try db.updateTranslation(id, .value(value))
            }
            
            if dropRegion {
                try db.updateTranslation(id, .region(nil))
            }
        }
    }
}
