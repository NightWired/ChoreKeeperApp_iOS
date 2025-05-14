# ErrorHandler

A Swift module for centralized error handling in the ChoreKeeper iOS application.

## Overview

The ErrorHandler module provides a comprehensive error handling system with the following features:

- Standardized error types and error codes
- Localized error messages using the LocalizationHandler module
- Error severity levels for appropriate UI presentation
- Error logging and reporting capabilities
- Middleware for intercepting and processing errors
- Presentation utilities for displaying errors to users

## Installation

### Swift Package Manager

Add the ErrorHandler package to your project by including it as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(name: "ErrorHandler", path: "../ErrorHandler")
]
```

## Usage

### Basic Error Creation

```swift
import ErrorHandler

// Create a simple error
let error = AppError(code: .invalidInput)

// Create an error with a custom message
let error = AppError(
    code: .invalidInput,
    message: "The username must be at least 3 characters long"
)

// Create an error with severity
let error = AppError(
    code: .networkError,
    severity: .high,
    message: "Failed to connect to the server"
)

// Create an error with an underlying error
do {
    try someRiskyOperation()
} catch {
    let appError = AppError(
        code: .operationFailed,
        severity: .medium,
        underlyingError: error
    )
    ErrorHandler.handle(appError)
}
```

### Error Handling

```swift
import ErrorHandler

// Handle an error (logs and processes the error)
ErrorHandler.handle(error)

// Present an error to the user
ErrorHandler.present(error, in: viewController)

// Get a localized error message
let message = ErrorHandler.localizedMessage(for: error)
```

### Error Middleware

```swift
import ErrorHandler

// Create a custom middleware
class LoggingMiddleware: ErrorMiddleware {
    func process(error: AppError, next: @escaping (AppError) -> Void) {
        // Log the error
        print("Error occurred: \(error.code.rawValue) - \(error.message ?? "No message")")

        // Call the next middleware in the chain
        next(error)
    }
}

// Register the middleware
ErrorHandler.registerMiddleware(LoggingMiddleware())
```

## Error Codes

The module defines a comprehensive set of error codes organized by category:

- General Errors (1-999)
- Network Errors (1000-1999)
- Authentication Errors (2000-2999)
- Data Errors (3000-3999)
- User Input Errors (4000-4999)
- Permission Errors (5000-5999)
- Chore Management Errors (6000-6999)
- Reward Management Errors (7000-7999)
- Point Management Errors (8000-8999)
- System Errors (9000-9999)

For a complete list of error codes, see the [Error Codes Reference](ERROR_CODES.md).

## Integration with LocalizationHandler

The ErrorHandler module integrates with the LocalizationHandler module to provide localized error messages. Error codes are mapped to localization keys in the format `errors.{errorCode}`.

## License

This project is licensed under the terms found in the LICENSE file.
