import Plot

extension HTML {
    static func make(with keys: [Key]) -> Self {
        return HTML(
            .head(
                .title("Localization Strings"),
                .style("""
                body {
                    font-family: -apple-system, Helvetica, sans-serif;
                }

                h1 {
                    color: purple;
                }

                h2 {
                    color: royalblue;
                }

                table, th, td {
                    border-collapse: collapse;
                    border: 1px solid gray;
                }

                th {
                    color: slategray;
                }
                """)
            ),
            .body(
                .div(
                    .h1("Strings")
                ),
                .forEach(keys) {
                    .localization($0)
                }
            )
        )
    }
}

extension Node where Context == HTML.BodyContext {
    static func localization(_ key: Key) -> Self {
        let values = key.values.sorted(by: { $0.language < $1.language })
        
        return .div(
            .h2(.text(key.name)),
            .p(.text(key.comment ?? "")),
            .table(
                .tr(
                    .th("Language/Region"),
                    .th("Localization")
                ),
                .forEach(values) {
                    .if($0.language == "en", .defaultValue($0), else: .value($0))
                }
            )
        )
    }
    
    
}

extension Node where Context == HTML.TableContext {
    static func value(_ value: Value) -> Self {
        return .tr(
            .td(
                .text(value.designator)
            ),
            .td(
                .text(value.localization)
            )
        )
    }
    
    static func defaultValue(_ value: Value) -> Self {
        return .tr(
            .td(
                .b(
                    .text(value.designator)
                )
            ),
            .td(
                .b(
                    .text(value.localization)
                )
            )
        )
    }
}

extension XML {
    static func make(with keys: [Key]) -> Self {
        return XML(
            .element(named: "resources", nodes: [
                .attribute(named: "xmlns:tools", value: "http://schemas.android.com/tools"),
                .forEach(keys) {
                    .element(named: "string", nodes: [
                        .attribute(named: "name", value: $0.name),
                        .text($0.values.first?.localization ?? "")
                    ])
                }
            ])
        )
    }
}
