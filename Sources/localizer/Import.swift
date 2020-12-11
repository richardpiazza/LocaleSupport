import Foundation
import ArgumentParser

struct Import: ParsableCommand {
    
    enum Source: String, ExpressibleByArgument {
        case android
        case apple
    }
    
    static var configuration: CommandConfiguration = .init(
        commandName: "import",
        abstract: "Imports an Android 'Strings.xml' or Apple 'Localizable.strings' file into the catalog.",
        discussion: "",
        version: "1.0.0",
        shouldDisplay: true,
        subcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong
    )
    
    @Argument(help: "The source of the file 'android' or 'apple'.")
    var source: Source
    
    @Argument(help: "The path to the file being imported")
    var input: String
    
    @Option(help: "The language code to use for the strings.")
    var language: LanguageCode = "en"
    
    @Option(help: "The region code to use for the strings.")
    var region: RegionCode?
    
    func validate() throws {
        guard !input.isEmpty else {
            throw ValidationError("'input' source file not provided.")
        }
        
        guard !language.isEmpty else {
            throw ValidationError("'language' must be specified.")
        }
    }
    
    func run() throws {
        let path = try FileManager.default.defaultCatalogPath()
        let db = try StringsDatabase(path: path)
        let url = try FileManager.default.url(for: input)
        
        let keys: [Key]
        switch source {
        case .android:
            let android = try StringsXml.make(contentsOf: url)
            keys = android.keys(language: language, region: region)
        case .apple:
            let dictionary = try Dictionary(contentsOf: url)
            keys = dictionary.keys(language: language, region: region)
        }
        
        try keys.forEach({
            try db.insert($0)
            let name = $0.name
            $0.values.forEach { (value) in
                print("Importing tag '\(name)' \(value.designator): '\(value.localization)'")
            }
        })
    }
}
