import Foundation

public struct Key: Identifiable {
    /// Unique (Primary Key)
    public var id: Int
    /// Identifying Name
    public var name: String
    /// Contextual Information
    public var comment: String?
    /// Localized representations of the matching value
    public var values: [Value]
    
    public init(id: Int = -1, name: String = "", comment: String? = nil, values: [Value] = []) {
        self.id = id
        self.name = name
        self.comment = comment
        self.values = values
    }
}
