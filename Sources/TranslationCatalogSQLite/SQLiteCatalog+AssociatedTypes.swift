import Foundation
import LocaleSupport
import TranslationCatalog

public extension SQLiteCatalog {
    
    enum Error: Swift.Error {
        case invalidAction(CatalogUpdate)
        case invalidQuery(CatalogQuery)
        case invalidPrimaryKey(Int)
        case invalidProjectID(Project.ID)
        case invalidExpressionID(Expression.ID)
        case invalidTranslationID(TranslationCatalog.Translation.ID)
        case invalidStringValue(String)
        case existingExpressionWithID(Expression.ID)
        case existingExpressionWithKey(String)
        case existingTranslationWithID(TranslationCatalog.Translation.ID)
        case unhandledQuery(CatalogQuery)
        case unhandledConversion
    }
    
    enum ProjectQuery: CatalogQuery {
        case hierarchy
        case primaryKey(Int)
        case id(Project.ID)
        case named(String)
    }
    
    enum ExpressionQuery: CatalogQuery {
        case hierarchy
        case primaryKey(Int)
        case id(Expression.ID)
        case projectID(Project.ID)
        case key(String)
        case named(String)
        /// Expressions with Translations the match the LanguageCode as well as the provided script/region.
        case having(LanguageCode, ScriptCode?, RegionCode?)
        /// Expressions with Translations that only match the provided LanguageCode. (Script == Null & Region == Null)
        case havingOnly(LanguageCode)
    }
    
    enum TranslationQuery: CatalogQuery {
        case primaryKey(Int)
        case id(TranslationCatalog.Translation.ID)
        case expressionID(Expression.ID)
        /// Translations that match all of the provided parameters
        case having(Expression.ID, LanguageCode, ScriptCode?, RegionCode?)
        /// Translations that match only the given parameters (Script == Null & Region == Null)
        case havingOnly(Expression.ID, LanguageCode)
    }
    
    enum ProjectUpdate: CatalogUpdate {
        case name(String)
        case linkExpression(Expression.ID)
        case unlinkExpression(Expression.ID)
    }
    
    enum ExpressionUpdate: CatalogUpdate {
        case key(String)
        case name(String)
        case defaultLanguage(LanguageCode)
        case context(String?)
        case feature(String?)
        case linkProject(Project.ID)
        case unlinkProject(Project.ID)
    }
    
    enum TranslationUpdate: CatalogUpdate {
        case language(LanguageCode)
        case script(ScriptCode?)
        case region(RegionCode?)
        case value(String)
    }
}
