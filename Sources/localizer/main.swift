import ArgumentParser

let configuration = Configuration.current
LanguageCode.default = configuration.defaultLanguageCode
RegionCode.default = configuration.defaultRegionCode

struct Command: ParsableCommand {
    static var configuration: CommandConfiguration = {
        return .init(
            commandName: "localizer",
            abstract: "Android 'strings.xml' & Apple 'Localizable.strings' utility.",
            discussion: """
            Default Language Code: \(LanguageCode.default.rawValue)
            Default Region Code: \(RegionCode.default.rawValue)
            """,
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [
                Preview.self,
                Catalog.self,
                Import.self,
                Export.self,
                Generate.self,
                Configure.self
            ],
            defaultSubcommand: Preview.self,
            helpNames: [.short, .long])
    }()
}

Command.main()
