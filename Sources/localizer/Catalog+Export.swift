import ArgumentParser
import Foundation
import Plot

extension Catalog {
    struct Export: ParsableCommand {
        
        enum Format: String, ExpressibleByArgument {
            case markdown
            case html
        }
        
        static var configuration: CommandConfiguration = .init(
            commandName: "export",
            abstract: "Exports the strings catalog to a viewable format.",
            discussion: "",
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
            
            let expressions = db.expressions(includeTranslations: true).sorted(by: { $0.name < $1.name })
            
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
                
                ## \(expression.name)
                \(expression.comment ?? "")
                
                | Language/Region | Localization |
                | --- | --- |
                """
                
                let translations = expression.translations.sorted(by: { $0.language.rawValue < $1.language.rawValue })
                translations.forEach { (translation) in
                    if translation.language == expression.defaultLanguage {
                        md += "| **\(translation.designator)** | **\(translation.value)** |"
                    } else {
                        md += "| \(translation.designator) | \(translation.value) |"
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
