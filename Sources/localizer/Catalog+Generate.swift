import ArgumentParser
import Foundation
import Plot

extension Catalog {
    struct Generate: ParsableCommand {
        
        enum Format: String, CaseIterable, ExpressibleByArgument {
            case markdown
            case html
        }
        
        static var configuration: CommandConfiguration = .init(
            commandName: "generate",
            abstract: "Generate a viewable document using the strings catalog.",
            discussion: """
            Available formats: \(Format.allCases.map{ $0.rawValue }.joined(separator: " "))
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "The export format")
        var format: Format
        
        @Option(help: "Overrides the default support directory path for the catalog database.")
        var catalogPath: String?
        
        func run() throws {
            let path = try catalogPath ?? FileManager.default.catalogURL().path
            let db = try SQLiteDatabase(path: path)
            
            let expressions = try db.expressions(includeTranslations: true).sorted(by: { $0.name < $1.name })
            
            switch format {
            case .markdown:
                exportMarkdown(expressions)
            case .html:
                exportHtml(expressions)
            }
        }
        
        private func exportMarkdown(_ expressions: [Expression]) {
            var md: String = "# Strings"
            
            expressions.forEach { (expression) in
                md += """
                \n
                ## \(expression.name)
                Id: \(expression.id)
                Comment: \(expression.comment ?? "")
                Feature: \(expression.feature ?? "")
                
                | ID | Language/Region | Localization |
                | --- | --- | --- |
                """
                
                let translations = expression.translations.sorted(by: { $0.languageCode.rawValue < $1.languageCode.rawValue })
                translations.forEach { (translation) in
                    if translation.language == expression.defaultLanguage {
                        md += "\n| **\(translation.id)** | **\(translation.designator)** | **\(translation.value)** |"
                    } else {
                        md += "\n| \(translation.id) | \(translation.designator) | \(translation.value) |"
                    }
                }
            }
            
            print(md)
        }
        
        private func exportHtml(_ expressions: [Expression]) {
            let html = HTML.make(with: expressions)
            print(html.render(indentedBy: .spaces(2)))
        }
    }
}
