import ArgumentParser
import Foundation
import LocaleSupport
import TranslationCatalog

extension Catalog {
    struct Update: ParsableCommand {
        static var configuration: CommandConfiguration = .init(
            commandName: "update",
            abstract: "Update a single entity in the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [
                ExpressionCommand.self,
                TranslationCommand.self
            ],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
    }
}

extension Catalog.Update {
    struct ProjectCommand: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "project",
            abstract: "Update a Project in the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Project.")
        var id: Project.ID
        
        @Option(help: "Name that identifies a collection of expressions.")
        var name: String?
        
        func validate() throws {
            if let name = self.name {
                guard !name.isEmpty else {
                    throw ValidationError("Must provide a non-empty 'name'.")
                }
            }
        }
        
        func run() throws {
            let catalog = try SQLiteCatalog()
            let project = try catalog.project(id)
            
            print("Updating Project '\(project.name) [\(project.uuid.uuidString)]'…")
            
            if let name = self.name {
                try catalog.updateProject(project, action: SQLiteCatalog.ProjectUpdate.name(name))
                print("Set Name to '\(name)'.")
            }
        }
    }
    
    struct ExpressionCommand: ParsableCommand {
        
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
        
        @Option(help: "Unique key that identifies the expression in translation files.")
        var key: String?
        
        @Option(help: "Name that identifies a collection of translations.")
        var name: String?
        
        @Option(help: "The default/development language code.")
        var defaultLanguage: LanguageCode?
        
        @Option(help: "Contextual information that guides translators.")
        var context: String?
        
        @Option(help: "Optional grouping identifier.")
        var feature: String?
        
        func validate() throws {
            if let key = self.key {
                guard !key.isEmpty else {
                    throw ValidationError("Must provide a non-empty 'key'.")
                }
            }
            
            if let name = self.name {
                guard !name.isEmpty else {
                    throw ValidationError("Must provide a non-empty 'name'.")
                }
            }
        }
        
        func run() throws {
            let catalog = try SQLiteCatalog()
            
            let expression = try catalog.expression(id)
            
            if let key = self.key, expression.key != key {
                try catalog.updateExpression(expression.id, action: SQLiteCatalog.ExpressionUpdate.key(key))
            }
            
            if let name = self.name, expression.name != name {
                try catalog.updateExpression(expression.id, action: SQLiteCatalog.ExpressionUpdate.name(name))
            }
            
            if let language = self.defaultLanguage, expression.defaultLanguage != language {
                try catalog.updateExpression(expression.id, action: SQLiteCatalog.ExpressionUpdate.defaultLanguage(language))
            }
            
            if let context = self.context, expression.context != context {
                let value = context.isEmpty ? nil : context
                try catalog.updateExpression(expression.id, action: SQLiteCatalog.ExpressionUpdate.context(value))
            }
            
            if let feature = self.feature, expression.feature != feature {
                let value = feature.isEmpty ? nil : feature
                try catalog.updateExpression(expression.id, action: SQLiteCatalog.ExpressionUpdate.feature(value))
            }
        }
    }
}

extension Catalog.Update {
    struct TranslationCommand: ParsableCommand {
        
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
        var id: TranslationCatalog.Translation.ID
        
        @Option(help: "Language of the translation.")
        var language: LanguageCode?
        
        @Option(help: "Script code specifier.")
        var script: ScriptCode?
        
        @Option(help: "Region code specifier.")
        var region: RegionCode?
        
        @Option(help: "The translated string.")
        var value: String?
        
        @Flag(help: "Forcefully drop the 'ScriptCode'. Does nothing when 'script' value provided.")
        var dropScript: Bool = false
        
        @Flag(help: "Forcefully drop the 'RegionCode'. Does nothing when 'region' value provided.")
        var dropRegion: Bool = false
        
        func run() throws {
            let catalog = try SQLiteCatalog()
            
            let translation = try catalog.translation(id)
            
            if let language = self.language, translation.languageCode != language {
                try catalog.updateTranslation(translation.id, action: SQLiteCatalog.TranslationUpdate.language(language))
            }
            
            if let script = self.script, translation.scriptCode != script {
                try catalog.updateTranslation(translation.id, action: SQLiteCatalog.TranslationUpdate.script(script))
            }
            
            if let region = self.region, translation.regionCode != region {
                try catalog.updateTranslation(translation.id, action: SQLiteCatalog.TranslationUpdate.region(region))
            }
            
            if let value = self.value, translation.value != value {
                try catalog.updateTranslation(translation.id, action: SQLiteCatalog.TranslationUpdate.value(value))
            }
            
            if dropScript && script == nil {
                try catalog.updateTranslation(translation.id, action: SQLiteCatalog.TranslationUpdate.script(nil))
            }
            
            if dropRegion && region == nil {
                try catalog.updateTranslation(translation.id, action: SQLiteCatalog.TranslationUpdate.region(nil))
            }
        }
    }
}
