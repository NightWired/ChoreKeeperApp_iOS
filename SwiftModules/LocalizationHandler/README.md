# LocalizationHandler

A Swift module for handling localization in the ChoreKeeper iOS application.

## Overview

LocalizationHandler provides a comprehensive solution for managing localization in iOS applications. It supports 17 languages and uses a nested key structure for organizing localization strings. The module uses a bundle-based approach to load localization files, making it suitable for use in any iOS application.

## Features

- Support for 17 languages
- Nested key structure for organized localization strings
- JSON-based localization files
- Bundle-based file loading with multiple fallback strategies
- Bundle registration system for modular localization
- Right-to-left (RTL) language support
- Language selection and persistence
- String formatting with arguments
- Fallback to default language when translations are missing
- Comprehensive debugging support
- Enhanced mock data for testing

## Requirements

- iOS 15.0+
- Swift 5.5+
- Xcode 14.2+

## Installation

### Swift Package Manager

To integrate LocalizationHandler into your Xcode project using Swift Package Manager:

1. In Xcode, select "File" > "Add Packages..."
2. Enter the package repository URL
3. Select "Up to Next Major Version" with the current version
4. Click "Add Package"

## Usage

### Basic Usage

```swift
import LocalizationHandler

// Get the localization service
let localizationService = LocalizationService()

// Register your app's bundle
LocalizationHandler.registerBundle(Bundle.main)

// Get a localized string
let welcomeMessage = LocalizationHandler.localize("onboarding.welcome.title")

// Get a localized string with arguments
let greeting = LocalizationHandler.localize("greeting.withName", with: "John")

// Change the language
LocalizationHandler.setLanguage(.french)

// Check if the current language is right-to-left
let isRTL = LocalizationHandler.isRightToLeft()

// Get debug information
let debugInfo = LocalizationHandler.debugLocalizationInfo()
```

### SwiftUI Integration

```swift
import SwiftUI
import LocalizationHandler

struct ContentView: View {
    var body: some View {
        VStack {
            Text(LocalizationHandler.localize("app.name"))
                .font(.largeTitle)

            Text(LocalizationHandler.localize("onboarding.welcome.title"))
                .font(.headline)

            // RTL support
            .multilineTextAlignment(LocalizationHandler.isRightToLeft() ? .trailing : .leading)
        }
    }
}
```

## Integration with Xcode Project

To integrate this module with your Xcode project:

1. Add the module as a dependency using Swift Package Manager
2. Place your localization JSON files in the appropriate directory structure:
   - `[YourApp]/LocalizationAssets/[language_code]/[language_code].json`
3. Initialize the localization service in your app's startup code:
   ```swift
   // In your App.swift or AppDelegate.swift
   LocalizationHandler.registerBundle(Bundle.main)
   ```
4. Use the localization service throughout your app for all user-facing strings

## License

This module is part of the ChoreKeeper application and is subject to the same license terms.
