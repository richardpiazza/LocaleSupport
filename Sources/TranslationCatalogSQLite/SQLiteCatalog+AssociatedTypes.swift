import Foundation
import LocaleSupport
import TranslationCatalog
import PerfectSQLite

public extension SQLiteCatalog {
    
    enum Error: Swift.Error {
        case invalidAction(CatalogUpdate)
        case invalidQuery(CatalogQuery)
        case invalidPrimaryKey(Int)
        case invalidProjectID(Project.ID)
        case invalidExpressionID(Expression.ID)
        case existingExpressionWithID(Expression.ID)
        case existingExpressionWithKey(String)
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
    
    enum InsertEntity: CatalogUpdate {
        case nothing
        case cascade
        case foreignKey(Int)
    }
    
    enum ProjectUpdate: CatalogUpdate {
        case name(String)
    }
    
    enum ExpressionUpdate: CatalogUpdate {
        case key(String)
        case name(String)
        case defaultLanguage(LanguageCode)
        case context(String?)
        case feature(String?)
    }
    
    enum TranslationUpdate: CatalogUpdate {
        case language(LanguageCode)
        case script(ScriptCode?)
        case region(RegionCode?)
        case value(String)
    }
}
