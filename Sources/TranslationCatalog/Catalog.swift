import Foundation
import LocaleSupport

/// Interface providing storage and retrieval of the `Expression`s and associated `Translation`s.
public protocol Catalog {
    // MARK: - Project
    func projects() throws -> [Project]
    func project(_ id: Project.ID) throws -> Project
    func project(matching query: CatalogQuery) throws -> Project
    func createProject(_ project: Project, action: CatalogAction) throws -> Project.ID
    func updateProject(_ project: Project, action: CatalogAction) throws
    func deleteProject(_ id: Project.ID, action: CatalogAction) throws
    
    // MARK: - Expression
    func expressions() throws -> [Expression]
    func expression(_ id: Expression.ID) throws -> Expression
    func expressions(for project: Project.ID) throws -> [Expression]
    func expressions(matching query: CatalogQuery) throws -> [Expression]
    func createExpression(_ expression: Expression, action: CatalogAction) throws -> Expression.ID
    func updateExpression(_ id: Expression.ID, action: CatalogAction) throws
    func deleteExpression(_ id: Expression.ID, action: CatalogAction) throws
    
    // MARK: - Translation
    func translations() throws -> [Translation]
    func translation(_ id: Translation.ID) throws -> Translation
    func translations(for expression: Expression.ID) throws -> [Translation]
    func translations(matching query: CatalogQuery) throws -> [Translation]
    func createTranslation(_ translation: Translation, action: CatalogAction) throws -> Translation.ID
    func updateTranslation(_ id: Translation.ID, action: CatalogAction) throws
    func deleteTranslation(_ id: Translation.ID, action: CatalogAction) throws
}

/// Associated action when performing CRUD operations
public protocol CatalogAction {}
/// Parameters for matching
public protocol CatalogQuery {}
