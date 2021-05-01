import Foundation
import LocaleSupport
import TranslationCatalog
import PerfectSQLite

public extension SQLiteCatalog {
    
    enum Error: Swift.Error {
        case invalidAction(CatalogAction)
        case invalidQuery(CatalogQuery)
        case invalidPrimaryKey(Int)
        case invalidProjectID(Project.ID)
        case invalidExpressionID(Expression.ID)
        case existingExpressionWithID(Expression.ID)
        case invalidTranslationID(TranslationCatalog.Translation.ID)
        case existingTranslationWithID(TranslationCatalog.Translation.ID)
        case unhandledConversion
    }
    
    enum Query: CatalogQuery {
        case cascade
        case primaryKey(Int)
        case primaryID(UUID)
        case foreignKey(Int)
        case foreignID(UUID)
        case expression(LanguageCode, ScriptCode?, RegionCode?)
        case translation(Expression.ID, LanguageCode, ScriptCode?, RegionCode?)
    }
    
    enum InsertEntity: CatalogAction {
        case nothing
        case cascade
        case foreignKey(Int)
    }
    
    enum ProjectUpdate: CatalogAction {
        case name(String)
    }
    
    enum ExpressionUpdate: CatalogAction {
        case key(String)
        case name(String)
        case defaultLanguage(LanguageCode)
        case context(String?)
        case feature(String?)
    }
    
    enum TranslationUpdate: CatalogAction {
        case language(LanguageCode)
        case script(ScriptCode?)
        case region(RegionCode?)
        case value(String)
    }
    
    enum DeleteEntity: CatalogAction {
        case nothing
        case cascade
    }
}
