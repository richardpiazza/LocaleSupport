import ArgumentParser
import Foundation
import Plot
import TranslationCatalog

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
        
        func run() throws {
            let catalog = try SQLiteCatalog()
            let expressions = try catalog.expressions().sorted(by: { $0.name < $1.name })
            
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
                Context: \(expression.context ?? "")
                Feature: \(expression.feature ?? "")
                
                | ID | Language/Region | Localization |
                | --- | --- | --- |
                """
                
                let translations = expression.translations.sorted(by: { $0.languageCode.rawValue < $1.languageCode.rawValue })
                translations.forEach { (translation) in
                    if translation.languageCode == expression.defaultLanguage {
                        md += "\n| **\(translation.id)** | **\(translation.localeIdentifier)** | **\(translation.value)** |"
                    } else {
                        md += "\n| \(translation.id) | \(translation.localeIdentifier) | \(translation.value) |"
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
