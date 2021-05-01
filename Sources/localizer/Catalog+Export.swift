import ArgumentParser
import Foundation
import Plot
import LocaleSupport
import TranslationCatalog
import TranslationCatalogSQLite

extension Catalog {
    struct Export: ParsableCommand {
        
        enum Format: String, ExpressibleByArgument {
            case android
            case apple
        }
        
        static var configuration: CommandConfiguration = .init(
            commandName: "export",
            abstract: "Export a translation file using the catalog.",
            discussion: """
            iOS Localization should contain all keys (expressions) for a given language. There is no native fallback
            mechanism to a 'base' language. (i.e. en-GB > en). Given this functionality, when exporting the 'apple'
            format, all expressions will be included (preferring the region). Use the '--force-region-match' flag to
            override this behavior.
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "The export format")
        var format: Format = .android
        
        @Argument(help: "The language code to use for the strings.")
        var language: LanguageCode
        
        @Argument(help: "TODO: Implement")
        var filename: String
        
        @Option(help: "The script code to use for the strings.")
        var script: ScriptCode?
        
        @Option(help: "The region code to use for the strings.")
        var region: RegionCode?
        
        @Flag(help: "Limit content to the explicitly defined RegionCode.")
        var forceRegionMatch: Bool = false
        
        @Option(help: "Overrides the default support directory path for the catalog database.")
        var catalogPath: String?
        
        func run() throws {
            let catalog = try SQLiteCatalog(path: try FileManager.default.catalogURL().path)
            
            var expressions: [Expression]
            if format == .apple && !forceRegionMatch {
                expressions = try catalog.expressions(matching: SQLiteCatalog.Query.expression(language, nil, nil))
            } else {
                expressions = try catalog.expressions(matching: SQLiteCatalog.Query.expression(language, script, region))
            }
            
            switch format {
            case .android:
                exportAndroid(expressions)
            case .apple:
                exportApple(expressions)
            }
        }
        
        private func exportAndroid(_ expressions: [Expression]) {
            let xml = XML.make(with: expressions)
            print(xml.render(indentedBy: .spaces(2)))
        }
        
        private func exportApple(_ expressions: [Expression]) {
            expressions.forEach { (expression) in
                guard let translation = expression.translations.first else {
                    return
                }
                
                print("\"\(expression.name)\" = \"\(translation.value)\";")
            }
        }
    }
}
