import Foundation
import ArgumentParser
import LocaleSupport
import TranslationCatalog

extension Catalog {
    struct Import: ParsableCommand {
        
        enum Format: String, ExpressibleByArgument {
            case android
            case apple
            
            init?(extension: String) {
                switch `extension`.lowercased() {
                case "xml":
                    self = .android
                case "strings":
                    self = .apple
                default:
                    return nil
                }
            }
        }
        
        static var configuration: CommandConfiguration = .init(
            commandName: "import",
            abstract: "Imports a translation file into the catalog.",
            discussion: """
            
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Argument(help: "The language code for the translations in the imported file.")
        var language: LanguageCode
        
        @Argument(help: "The path to the file being imported")
        var filename: String
        
        @Option(help: "The source of the file 'android' or 'apple'.")
        var format: Format?
        
        @Option(help: "The script code for the translations in the imported file.")
        var script: ScriptCode?
        
        @Option(help: "The region code for the translations in the imported file.")
        var region: RegionCode?
        
        @Option(help: "The 'default' Language for the expressions being imported.")
        var defaultLanguage: LanguageCode = .default
        
        func validate() throws {
            guard !filename.isEmpty else {
                throw ValidationError("'input' source file not provided.")
            }
        }
        
        func run() throws {
            let url = try FileManager.default.url(for: filename)
            
            let _format = format ?? Format(extension:  url.pathExtension)
            guard let fileFormat = _format else {
                throw ValidationError("Import format could not be determined. Use '--format' to specify.")
            }
            
            let catalog = try SQLiteCatalog()
            
            let expressions: [Expression]
            switch fileFormat {
            case .android:
                let android = try StringsXml.make(contentsOf: url)
                expressions = android.expressions(language: language, region: region)
            case .apple:
                let dictionary = try Dictionary(contentsOf: url)
                expressions = dictionary.expressions(language: language, region: region)
            }
            
            try expressions.forEach({
                _ = try catalog.createExpression($0, action: SQLiteCatalog.InsertEntity.cascade)
            })
        }
    }
}
