import Foundation
import ArgumentParser

struct Catalog: ParsableCommand {
    
    static var configuration: CommandConfiguration = .init(
        commandName: "catalog",
        abstract: "Interact with the translation catalog.",
        discussion: """
        """,
        version: "1.0.0",
        shouldDisplay: true,
        subcommands: [
            Import.self,
            Export.self,
            Generate.self
        ],
        defaultSubcommand: nil,
        helpNames: .shortAndLong
    )
    
}
