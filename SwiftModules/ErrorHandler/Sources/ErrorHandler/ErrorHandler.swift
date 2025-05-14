//
//  ErrorHandler.swift
//  ErrorHandler
//
//  Created on 2023-05-16.
//

import Foundation
import LocalizationHandler

/// Main entry point for error handling in the application
public class ErrorHandler {
    // MARK: - Properties

    /// Shared instance of the error handler
    public static let shared = ErrorHandler()

    /// Middleware for processing errors
    private var middleware: [ErrorMiddleware] = []

    /// The localization service
    private let localizationService: LocalizationServiceProtocol

    // MARK: - Initialization

    /// Creates a new error handler
    /// - Parameter localizationService: The localization service to use
    public init(localizationService: LocalizationServiceProtocol = LocalizationHandler.shared) {
        self.localizationService = localizationService

        // Register default middleware
        registerMiddleware(LoggingMiddleware())

        // Setup localized message handler
        setupLocalizedMessage()
    }

    // MARK: - Static Methods

    /// Handle an error
    /// - Parameter error: The error to handle
    public static func handle(_ error: Error) {
        // Convert to AppError if needed
        let appError = error as? AppError ?? AppError.from(error)

        // Process the error through middleware
        shared.processError(appError)
    }

    /// Get a localized message for an error
    /// - Parameter error: The error to get a message for
    /// - Returns: The localized message
    public static func localizedMessage(for error: Error) -> String {
        return shared.localizedMessage(error)
    }

    /// Register middleware for processing errors
    /// - Parameter middleware: The middleware to register
    public static func registerMiddleware(_ middleware: ErrorMiddleware) {
        shared.registerMiddleware(middleware)
    }

    // MARK: - Instance Methods

    /// Register middleware for processing errors
    /// - Parameter middleware: The middleware to register
    public func registerMiddleware(_ middleware: ErrorMiddleware) {
        self.middleware.append(middleware)
    }

    /// Process an error through middleware
    /// - Parameter error: The error to process
    public func processError(_ error: AppError) {
        // If there's no middleware, just log the error
        guard !middleware.isEmpty else {
            print("Error: \(error.formattedCode) - \(error.message ?? "No message")")
            return
        }

        // Create a chain of middleware
        var middlewareIndex = 0

        // Function to call the next middleware in the chain
        func next(_ error: AppError) {
            // If we've processed all middleware, we're done
            guard middlewareIndex < middleware.count else {
                return
            }

            // Get the next middleware
            let currentMiddleware = middleware[middlewareIndex]
            middlewareIndex += 1

            // Process the error with the middleware
            currentMiddleware.process(error: error, next: next)
        }

        // Start the middleware chain
        next(error)
    }

    /// Get a localized message for an error
    /// - Parameter error: The error to get a message for
    /// - Returns: The localized message
    public var localizedMessage: (Error) -> String = { _ in "" }

    /// Initialize the localizedMessage property
    private func setupLocalizedMessage() {
        localizedMessage = { [weak self] error in
            guard let self = self else {
                return "Error handler deallocated"
            }

            // Convert to AppError if needed
            let appError = error as? AppError ?? AppError.from(error)

            // If the error has a custom message, use it
            if let message = appError.message {
                return message
            }

            // Otherwise, try to get a localized message from the localization service
            let localizedMessage = self.localizationService.localize(appError.code.localizationKey)

            // If the localized message is the same as the key, it means the key wasn't found
            // In that case, return a generic error message with the error code
            if localizedMessage == appError.code.localizationKey {
                return "Error \(appError.formattedCode): An error occurred"
            }

            // Always include the error code in the localized message
            return "Error \(appError.formattedCode): \(localizedMessage)"
        }
    }
}
