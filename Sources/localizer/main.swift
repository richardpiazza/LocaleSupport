import ArgumentParser

struct Command: ParsableCommand {
    static var configuration: CommandConfiguration = {
        return .init(
            commandName: "localizer",
            abstract: "Android 'strings.xml' & Apple 'Localizable.strings' utility.",
            discussion: "",
            version: "1.0.0",
            shouldDisplay: true,
            subcommands: [
                Preview.self,
                Import.self,
                Export.self,
                Generate.self,
            ],
            defaultSubcommand: Preview.self,
            helpNames: [.short, .long])
    }()
}

Command.main()
