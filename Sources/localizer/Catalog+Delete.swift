import ArgumentParser
import Foundation
import TranslationCatalog

extension Catalog {
    struct Delete: ParsableCommand {
        static var configuration: CommandConfiguration = .init(
            commandName: "delete",
            abstract: "Remove a single entity in the catalog.",
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

extension Catalog.Delete {
    struct ExpressionEntity: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "expression",
            abstract: "Delete an Expression from the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Expression.")
        var id: Expression.ID
        
        func run() throws {
            let catalog = try SQLiteCatalog()
            try catalog.deleteExpression(id, action: SQLiteCatalog.DeleteEntity.cascade)
        }
    }
}

extension Catalog.Delete {
    struct TranslationEntity: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "translation",
            abstract: "Delete a Translation from the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "Unique ID of the Translation.")
        var id: TranslationCatalog.Translation.ID
        
        func run() throws {
            let catalog = try SQLiteCatalog()
            try catalog.deleteTranslation(id, action: SQLiteCatalog.DeleteEntity.nothing)
        }
    }
}
