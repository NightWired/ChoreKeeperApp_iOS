# LocalizationHandler Integration Guide

This document provides instructions for integrating the LocalizationHandler module into the ChoreKeeper iOS application.

## Overview

The LocalizationHandler module provides localization support for the ChoreKeeper app, with support for 17 languages and a nested key structure for organizing localization strings.

## Integration Steps

### 1. Add the Module to Your Xcode Project

Add the LocalizationHandler module to your Xcode project using Swift Package Manager:

1. In Xcode, select "File" > "Add Packages..."
2. Enter the package repository URL
3. Select "Up to Next Major Version" with the current version
4. Click "Add Package"

Alternatively, you can add the module as a local package:

1. In Xcode, select "File" > "Add Packages..."
2. Click "Add Local..."
3. Navigate to `/Users/baribyquance-hearn/Documents/augment-projects/ChoreKeeperProject/ChoreKeeper/SwiftModules/LocalizationHandler`
4. Click "Add Package"

### 2. Import the Module

Import the module in your Swift files:

```swift
import LocalizationHandler
```

### 3. Initialize the Localization Service

Initialize the localization service in your app's startup code, typically in `AppDelegate.swift` or `SceneDelegate.swift`:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize localization
    let localizationService = LocalizationService()

    // Set the initial language (optional, defaults to device language)
    // localizationService.setLanguage(.english)

    return true
}
```

### 4. Use the Localization Service

Use the localization service throughout your app for all user-facing strings:

```swift
// Using the shared instance
let welcomeMessage = LocalizationHandler.localize("onboarding.welcome.title")

// Using a localization service instance
let localizationService = LocalizationService()
let welcomeMessage = localizationService.localize("onboarding.welcome.title")

// Using string extension
let welcomeMessage = "onboarding.welcome.title".localized()

// With arguments
let greeting = LocalizationHandler.localize("greeting.withName", with: "John")
```

### 5. Handle Language Changes

Listen for language changes to update your UI:

```swift
NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name("LanguageChanged"), object: nil)

@objc func languageChanged() {
    // Update UI with new language
    updateUI()
}
```

### 6. Use RTL Support

Use the RTL support utilities for right-to-left languages:

```swift
// Check if current language is RTL
if LocalizationHandler.isRightToLeft() {
    // Adjust layout for RTL
}

// Get text alignment for current language
let textAlignment = RTLSupport.textAlignment()

// Get horizontal alignment for current language
let horizontalAlignment = RTLSupport.horizontalAlignment()

// Get edge insets for current language
let edgeInsets = RTLSupport.edgeInsets(leading: 16, trailing: 8)
```

## Localization Files

The module expects localization files to be in the following structure:

```
[YourApp]/LocalizationAssets/[language_code]/[language_code].json
```

For example:
- `/Users/baribyquance-hearn/Documents/augment-projects/ChoreKeeperProject/ChoreKeeper/ChoreKeeper/LocalizationAssets/en/en.json`
- `/Users/baribyquance-hearn/Documents/augment-projects/ChoreKeeperProject/ChoreKeeper/ChoreKeeper/LocalizationAssets/es/es.json`

The JSON files should use a nested key structure:

```json
{
  "section": {
    "subsection": {
      "key": "value"
    }
  }
}
```

## Customization

### Custom Localization File Path

To use a custom path for localization files, you'll need to modify the `LocalizationManager.swift` file to load files from your custom path.

### Custom Language Storage

By default, the selected language is stored in `UserDefaults` with the key `"app_language"`. If you need to use a different storage mechanism, you'll need to modify the `LocalizationManager.swift` file.

## Troubleshooting

### Missing Localization Files

If localization files are missing, the module will fall back to the default language (English). Make sure your localization files are in the correct location and have the correct structure.

### Language Not Changing

If the language is not changing when you call `setLanguage`, make sure you're calling it on the correct instance of the localization service.

## Contact

For questions or issues, please contact the development team.
