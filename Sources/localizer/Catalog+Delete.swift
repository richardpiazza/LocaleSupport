import ArgumentParser
import Foundation

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
        
        @Option(help: "Overrides the default support directory path for the catalog database.")
        var catalogPath: String?
        
        func run() throws {
            let path = try catalogPath ?? FileManager.default.catalogURL().path
            let db = try SQLiteDatabase(path: path)
            
            guard let _ = db.expression(id) else {
                print("No Expression found with id '\(id)'.")
                return
            }
            
            try db.deleteExpression(id)
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
        var id: Translation.ID
        
        @Option(help: "Overrides the default support directory path for the catalog database.")
        var catalogPath: String?
        
        func run() throws {
            let path = try catalogPath ?? FileManager.default.catalogURL().path
            let db = try SQLiteDatabase(path: path)
            
            guard let _ = db.translation(id) else {
                print("No Translation found with id '\(id)'.")
                return
            }
            
            try db.deleteTranslation(id)
        }
    }
}
