# LocaleSupport

Swift references and extensions for app localization &amp; internationalization.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frichardpiazza%2FLocaleSupport%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/richardpiazza/LocaleSupport)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frichardpiazza%2FLocaleSupport%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/richardpiazza/LocaleSupport)

## Usage

**LocaleSupport** is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, add it as 
a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/richardpiazza/LocaleSupport.git", .upToNextMinor(from: "0.4.0"))
    ],
    ...
)
```

Then import the **LocaleSupport** packages wherever you'd like to use it:

```swift
import LocaleSupport
```

## Targets

### LocaleSupport

This module is focused on implementing localized strings within apps themselves. Highlighted by the `LocalizedStringConvertible` protocol.

**Apple Platforms Note**:

As of `macOS 13`, `iOS 16`, `tvOS 16` & `watchOS 9`, the `Locale` type includes support for many of the extensions in this package:

* `Locale.LanguageCode`
* `Locale.Script`
* `Locale.Region`
* `Locale.Components`

## Contribution

Contributions to **LocaleSupport** are welcomed and encouraged!
