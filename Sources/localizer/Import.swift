import Foundation
import ArgumentParser

struct Import: ParsableCommand {
    
    enum Format: String, ExpressibleByArgument {
        case android
        case apple
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
    
    @Argument(help: "The source of the file 'android' or 'apple'.")
    var format: Format
    
    @Argument(help: "The path to the file being imported")
    var filename: String
    
    @Option(help: "The 'default' Language for the expressions being imported.")
    var defaultLanguage: LanguageCode = .default
    
    @Option(help: "The language code for the translations in the imported file.")
    var language: LanguageCode = .default
    
    @Option(help: "The region code for the translations in the imported file.")
    var region: RegionCode?
    
    func validate() throws {
        guard !filename.isEmpty else {
            throw ValidationError("'input' source file not provided.")
        }
    }
    
    func run() throws {
        let path = try FileManager.default.defaultCatalogPath()
        let db = try SQLiteDatabase(path: path)
        let url = try FileManager.default.url(for: filename)
        
        let expressions: [Expression]
        switch format {
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
