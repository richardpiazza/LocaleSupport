import ArgumentParser
import Foundation

struct Configure: ParsableCommand {
    
    struct Get: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "get",
            abstract: "Gets configuration parameters.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        func run() throws {
            print(Configuration.current.description)
        }
    }
    
    struct Set: ParsableCommand {
        
        static var configuration: CommandConfiguration = .init(
            commandName: "set",
            abstract: "Sets configuration parameters.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [],
            defaultSubcommand: nil,
            helpNames: .shortAndLong
        )
        
        @Option(help: "")
        var defaultLanguage: LanguageCode?
        
        @Option(help: "")
        var defaultRegion: RegionCode?
        
        func run() throws {
            var config = Configuration.current
            
            if let language = defaultLanguage {
                print("Set 'defaultLanguageCode' = '\(language.rawValue)'; was \(config.defaultLanguageCode.rawValue)")
                config.defaultLanguageCode = language
            }
            
            if let region = defaultRegion {
                print("Set 'defaultRegionCode' = '\(region.rawValue)'; was \(config.defaultRegionCode.rawValue)")
                config.defaultRegionCode = region
            }
            
            try Configuration.save(config)
        }
    }
    
    static var configuration: CommandConfiguration = .init(
        commandName: "configure",
        abstract: "Displays or alters the command configuration details.",
        discussion: "",
        version: "1.0.0",
        shouldDisplay: true,
        subcommands: [
            Get.self,
            Set.self
        ],
        defaultSubcommand: Get.self,
        helpNames: .shortAndLong
    )
}
