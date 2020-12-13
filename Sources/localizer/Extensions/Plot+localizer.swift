import Plot

extension HTML {
    static func make(with expressions: [Expression]) -> Self {
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
                .forEach(expressions) {
                    .localization($0)
                }
            )
        )
    }
}

extension Node where Context == HTML.BodyContext {
    static func localization(_ expression: Expression) -> Self {
        let values = expression.translations.sorted(by: { $0.language.rawValue < $1.language.rawValue })
        
        return .div(
            .h2(.text(expression.name)),
            .p(.text(expression.comment ?? "")),
            .table(
                .tr(
                    .th("Language/Region"),
                    .th("Localization")
                ),
                .forEach(values) {
                    .if($0.language == expression.defaultLanguage, .defaultValue($0), else: .value($0))
                }
            )
        )
    }
    
    
}

extension Node where Context == HTML.TableContext {
    static func value(_ translation: Translation) -> Self {
        return .tr(
            .td(
                .text(translation.designator)
            ),
            .td(
                .text(translation.value)
            )
        )
    }
    
    static func defaultValue(_ translation: Translation) -> Self {
        return .tr(
            .td(
                .b(
                    .text(translation.designator)
                )
            ),
            .td(
                .b(
                    .text(translation.value)
                )
            )
        )
    }
}

extension XML {
    static func make(with expressions: [Expression]) -> Self {
        return XML(
            .element(named: "resources", nodes: [
                .attribute(named: "xmlns:tools", value: "http://schemas.android.com/tools"),
                .forEach(expressions) {
                    .element(named: "string", nodes: [
                        .attribute(named: "name", value: $0.name),
                        .text($0.translations.first?.value ?? "")
                    ])
                }
            ])
        )
    }
}
