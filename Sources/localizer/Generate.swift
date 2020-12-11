import ArgumentParser
import Foundation
import Plot

struct Generate: ParsableCommand {
    
    enum Format: String, ExpressibleByArgument {
        case android
        case apple
    }
    
    static var configuration: CommandConfiguration = .init(
        commandName: "generate",
        abstract: "Generate a localization file.",
        discussion: "",
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
    
    @Argument(help: "")
    var filename: String
    
    @Option(help: "The region code to use for the strings.")
    var region: RegionCode?
    
    func validate() throws {
        guard !language.isEmpty else {
            throw ValidationError("'language' must be specified.")
        }
    }
    
    func run() throws {
        let path = try FileManager.default.defaultCatalogPath()
        let db = try StringsDatabase(path: path)
        let keys = db.keys(havingLanguage: language, region: region).sorted(by: { $0.name < $1.name })
        
        switch format {
        case .android:
            exportAndroid(keys)
        case .apple:
            exportApple(keys)
        }
    }
    
    private func exportAndroid(_ keys: [Key]) {
        let xml = XML.make(with: keys)
        print(xml.render(indentedBy: .spaces(2)))
    }
    
    private func exportApple(_ keys: [Key]) {
        keys.forEach { (key) in
            guard let value = key.values.first else {
                return
            }
            
            print("\"\(key.name)\" = \"\(value.localization)\";")
        }
    }
}
