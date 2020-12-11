import ArgumentParser
import Foundation
import Plot

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
    
    @Option(help: "The export format")
    var format: Format = .html
    
    func run() throws {
        let path = try FileManager.default.defaultCatalogPath()
        let db = try StringsDatabase(path: path)
        let keys = db.keys(includeValues: true).sorted(by: { $0.name < $1.name })
        
        switch format {
        case .markdown:
            exportMarkdown(keys)
        case .html:
            exportHtml(keys)
        }
    }
    
    private func exportMarkdown(_ keys: [Key]) {
        var md: String = "# Strings"
        
        keys.forEach { (key) in
            md += """
            
            ## \(key.name)
            \(key.comment ?? "")
            
            | Language/Region | Localization |
            | --- | --- |
            """
            
            let values = key.values.sorted(by: { $0.language < $1.language })
            values.forEach { (value) in
                if value.language == "en" {
                    md += "| **\(value.designator)** | **\(value.localization)** |"
                } else {
                    md += "| \(value.designator) | \(value.localization) |"
                }
            }
        }
        
        print(md)
    }
    
    private func exportHtml(_ keys: [Key]) {
        let html = HTML.make(with: keys)
        print(html.render(indentedBy: .spaces(2)))
    }
}
