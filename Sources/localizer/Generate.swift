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
        abstract: "Generates a translation file from the catalog.",
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
    
    func run() throws {
        let path = try FileManager.default.defaultCatalogPath()
        let db = try SQLiteDatabase(path: path)
        let expressions = db.expressions(having: language, region: region).sorted(by: { $0.name < $1.name })
        
        switch format {
        case .android:
            exportAndroid(expressions)
        case .apple:
            exportApple(expressions)
        }
    }
    
    private func exportAndroid(_ expressions: [Expression]) {
        let xml = XML.make(with: expressions)
        print(xml.render(indentedBy: .spaces(2)))
    }
    
    private func exportApple(_ expressions: [Expression]) {
        expressions.forEach { (expression) in
            guard let translation = expression.translations.first else {
                return
            }
            
            print("\"\(expression.name)\" = \"\(translation.value)\";")
        }
    }
}
