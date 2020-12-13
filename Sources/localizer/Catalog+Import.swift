import Foundation
import ArgumentParser

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
        
        @Option(help: "The region code for the translations in the imported file.")
        var region: RegionCode?
        
        @Option(help: "The 'default' Language for the expressions being imported.")
        var defaultLanguage: LanguageCode = .default
        
        @Option(help: "Overrides the default support directory path for the catalog database.")
        var catalogPath: String?
        
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
            
            let path = try catalogPath ?? FileManager.default.catalogURL().path
            let db = try SQLiteDatabase(path: path)
            
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
                try db.insert($0)
                let name = $0.name
                $0.translations.forEach { (translation) in
                    print("Importing tag '\(name)' \(translation.designator): '\(translation.value)'")
                }
            })
        }
    }
}
