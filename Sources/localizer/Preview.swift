import ArgumentParser
import Foundation

struct Preview: ParsableCommand {
    
    enum Source: String, ExpressibleByArgument {
        case android
        case apple
    }
    
    static var configuration: CommandConfiguration = .init(
        commandName: "preview",
        abstract: "Outputs the localizations found in the provided file.",
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
    
    func validate() throws {
        guard !input.isEmpty else {
            throw ValidationError("'input' source file not provided.")
        }
    }
    
    func run() throws {
        let url = try FileManager.default.url(for: input)
        
        let keys: [Key]
        switch source {
        case .android:
            let android = try StringsXml.make(contentsOf: url)
            keys = android.keys(language: "", region: nil)
        case .apple:
            let dictionary = try Dictionary(contentsOf: url)
            keys = dictionary.keys(language: "", region: nil)
        }
        
        keys.sorted(by: { $0.name < $1.name }).forEach { (key) in
            switch key.values.count {
            case .zero:
                print("\(key.name) NO LOCALIZATIONS")
            default:
                key.values.forEach { (value) in
                    print("\(key.name) = \(value.localization)")
                }
            }
        }
    }
}
