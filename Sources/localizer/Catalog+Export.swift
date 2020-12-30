import ArgumentParser
import Foundation
import Plot

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
            format, all expressions will be included (preferring the region). Use the '--region-match-only' flag to
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
        
        @Option(help: "The region code to use for the strings.")
        var region: RegionCode?
        
        @Flag(help: "Limit content to ")
        var regionMatchOnly: Bool = false
        
        @Option(help: "Overrides the default support directory path for the catalog database.")
        var catalogPath: String?
        
        func run() throws {
            let path = try catalogPath ?? FileManager.default.catalogURL().path
            let db = try SQLiteDatabase(path: path)
            
            let expressions = try db.expressions(having: language, region: region, fallback: !regionMatchOnly).sorted(by: { $0.name < $1.name })
            
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
