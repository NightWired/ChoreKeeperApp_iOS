# CoreServices

A Swift module providing core functionality and utilities for the ChoreKeeper iOS application.

## Overview

The CoreServices module serves as the foundation for the ChoreKeeper app, providing essential utilities and services that are used by all other modules. It includes logging, configuration management, dependency injection, common protocols, extensions, and various utility functions.

## Features

- **Logging System**: Centralized logging with different severity levels, file-based and console logging options
- **Configuration Management**: Environment-specific configuration, feature flag management, app settings management
- **Dependency Injection Framework**: Service locator pattern implementation, dependency registration and resolution
- **Common Protocols and Extensions**: Base protocols, Swift standard library extensions, Foundation framework extensions
- **Date and Time Utilities**: Date formatting with localization support, time zone handling, date calculations
- **String Formatting Utilities**: String validation, transformation, regular expression utilities
- **Security Utilities**: Encryption/decryption, secure storage helpers, data protection

## Installation

### Swift Package Manager

Add the CoreServices package to your project by including it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(name: "CoreServices", path: "../CoreServices")
]
```

## Usage

### Logging

```swift
import CoreServices

// Log messages with different severity levels
Logger.debug("Debug message")
Logger.info("Info message")
Logger.warning("Warning message")
Logger.error("Error message")
Logger.critical("Critical message")

// Log with context
Logger.info("User logged in", context: ["userId": "12345"])
```

### Configuration

```swift
import CoreServices

// Access configuration values
let apiUrl = Configuration.shared.getValue(for: "api.baseUrl")
let isFeatureEnabled = Configuration.shared.isFeatureEnabled("newRewardsSystem")

// Register configuration values
Configuration.shared.register(value: "https://api.example.com", for: "api.baseUrl")
Configuration.shared.registerFeature(name: "newRewardsSystem", isEnabled: true)
```

### Dependency Injection

```swift
import CoreServices

// Register a service
DependencyContainer.shared.register(UserService.self) { _ in
    return UserServiceImpl()
}

// Resolve a service
let userService = DependencyContainer.shared.resolve(UserService.self)
```

### Date Utilities

```swift
import CoreServices

// Format a date with localization
let formattedDate = DateUtilities.format(date, style: .medium)

// Calculate date differences
let daysBetween = DateUtilities.daysBetween(startDate, endDate)

// Check if a date is within a time period
let isWithinWeek = DateUtilities.isDate(date, within: .week, of: referenceDate)
```

### String Utilities

```swift
import CoreServices

// Validate strings
let isValidEmail = StringUtilities.isValidEmail("user@example.com")

// Transform strings
let slugified = StringUtilities.slugify("Hello World")
```

### Security Utilities

```swift
import CoreServices

// Encrypt/decrypt data
let encrypted = SecurityUtilities.encrypt(data, with: key)
let decrypted = SecurityUtilities.decrypt(encryptedData, with: key)

// Securely store sensitive information
SecurityUtilities.storeSecurely(password, for: "userAccount")
let retrievedPassword = SecurityUtilities.retrieveSecurely(for: "userAccount")
```

## Dependencies

- **LocalizationHandler**: Used for localized logging messages, date formatting, and error messages
- **ErrorHandler**: Used for standardized error reporting and logging

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.7+
- Xcode 14.0+

## License

This project is proprietary and confidential. Unauthorized copying, transfer, or reproduction of the contents of this module is strictly prohibited.

## Contact

For questions or issues with the CoreServices module, please contact the development team.
