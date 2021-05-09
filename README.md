# LocaleSupport

Swift toolkit for managing app localization &amp; internationalization.

<p>
  <img src="https://github.com/richardpiazza/LocaleSupport/workflows/Swift/badge.svg?branch=main" />
  <img src="https://img.shields.io/badge/Swift-5.3-orange.svg" />
  <a href="https://twitter.com/richardpiazza">
    <img src="https://img.shields.io/badge/twitter-@richardpiazza-blue.svg?style=flat" alt="Twitter: @richardpiazza" />
  </a>
</p>

## Packages

This toolkit is comprised of several components:

*  **LocaleSupport**: This module is focused on implementing localized strings within apps themselves. Highlighted by the `ExpressibleByLocalizedString` protocol.
* **TranslationCatalog**: Entity definitions for a lightweight catalog that can persist and retrieve translations.
* **TranslationCatalogSQLite**: A cross-platform SQLite implementation of the _Translation Catalog_.
* **localizer**: A swift command line that can interact with a catalog along with importing, exporting, and documenting localizations.

## LocaleSupport Module

### `ExpressibleByLocalizedString`

<info needed>

### `LanguageCode`, `ScriptCode`, `RegionCode`

<info needed>

## TranslationCatalog Module

### `Catalog`

<info needed>

## TranslationCatalogSQLite Module

### `Statement`

<info needed>

## `localizer` Executable

<info needed>

## Usage

**LocaleSupport** is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, add it as 
a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/richardpiazza/LocaleSupport.git", .upToNextMinor(from: "0.3.0"))
    ],
    ...
)
```

Then import the **LocaleSupport** packages wherever you'd like to use it:

```swift
import LocaleSupport
```

## Contribution

Contributions to **LocaleSupport** are welcomed and encouraged!
