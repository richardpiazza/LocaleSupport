import ArgumentParser
import TranslationCatalog
import TranslationCatalogSQLite
import Foundation

extension Catalog {
    struct Query: ParsableCommand {
        static var configuration: CommandConfiguration = .init(
            commandName: "query",
            abstract: "Perform queries against the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [
                ProjectCommand.self,
                ExpressionCommand.self,
//                TranslationCommand.self
            ],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
    }
}

extension Catalog.Query {
    struct ProjectCommand: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "project",
            abstract: "Query for projects in the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Option(help: "Partial name search")
        var named: String?
        
        func validate() throws {
            if let named = self.named {
                guard !named.isEmpty else {
                    throw ValidationError("Must provide a non-empty value for 'named'.")
                }
            }
        }
        
        func run() throws {
            let catalog = try SQLiteCatalog(url: try FileManager.default.catalogURL())
            
            var projects: [Project] = []
            
            if let named = self.named {
                projects = try catalog.projects(matching: SQLiteCatalog.ProjectQuery.named(named))
            } else {
                projects = try catalog.projects()
            }
            
            printHeader(nameLength: projects.nameLength)
            projects.forEach { project in
                printProject(project)
            }
        }
        
        private func printHeader(nameLength: Int) {
            print(
                "| " +
                "Project.ID".padding(toLength: UUID.zero.uuidString.count, withPad: " ", startingAt: 0) +
                " | " +
                "Name".padding(toLength: max(nameLength, 4), withPad: " ", startingAt: 0) +
                " |"
            )
        }
        
        private func printProject(_ project: Project) {
            print("| \(project.id.uuidString) | \(project.name) |")
        }
    }
    
    struct ExpressionCommand: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "expression",
            abstract: "Query for expressions in the catalog.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Option(help: "Unique key used in localization files.")
        var key: String?
        
        @Option(help: "A descriptive human-readable identification.")
        var named: String?
        
        func validate() throws {
            if let named = self.named {
                guard !named.isEmpty else {
                    throw ValidationError("Must provide a non-empty value for 'named'.")
                }
            }
        }
        
        func run() throws {
            let catalog = try SQLiteCatalog(url: try FileManager.default.catalogURL())
            
            var expressions: [Expression] = []
            
            if let key = self.key {
                expressions = try catalog.expressions(matching: SQLiteCatalog.ExpressionQuery.key(key))
            } else if let named = self.named {
                expressions = try catalog.expressions(matching: SQLiteCatalog.ExpressionQuery.named(named))
            } else {
                expressions = try catalog.expressions()
            }
            
            printHeader(keyLength: 0, nameLength: 0)
            expressions.forEach { expression in
                printExpression(expression)
            }
        }
        
        private func printHeader(keyLength: Int, nameLength: Int) {
            print(
                "| " +
                "Expression.ID".padding(toLength: UUID.zero.uuidString.count, withPad: " ", startingAt: 0) +
                " | " +
                "Key".padding(toLength: keyLength, withPad: " ", startingAt: 0) +
                " | " +
                "Name".padding(toLength: nameLength, withPad: " ", startingAt: 0) +
                " |"
            )
        }
        
        private func printExpression(_ expression: Expression) {
//            print("| \(project.id.uuidString) | \(project.name) |")
        }
    }
}

extension Array where Element == Project {
    var nameLength: Int { Swift.max(map { $0.name.count }.max() ?? 0, 4) }
}
