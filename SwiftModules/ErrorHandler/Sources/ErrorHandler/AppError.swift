//
//  AppError.swift
//  ErrorHandler
//
//  Created on 2023-05-16.
//

import Foundation

/// A standardized error type for the application
public struct AppError: Error, Identifiable, Equatable {
    // MARK: - Properties

    /// The unique identifier for the error
    public let id: String

    /// The error code
    public let code: AppErrorCode

    /// The severity of the error
    public let severity: ErrorSeverity

    /// An optional custom message for the error
    public let message: String?

    /// The underlying error, if any
    public let underlyingError: Error?

    /// The timestamp when the error occurred
    public let timestamp: Date

    /// Additional context information for the error
    public let context: [String: Any]

    // MARK: - Computed Properties

    /// The localized message for the error
    public var localizedMessage: String {
        return ErrorHandler.shared.localizedMessage(self)
    }

    /// The formatted error code (e.g., E0001)
    public var formattedCode: String {
        return code.formattedCode
    }

    // MARK: - Initialization

    /// Creates a new app error
    /// - Parameters:
    ///   - id: The unique identifier for the error (defaults to a new UUID)
    ///   - code: The error code
    ///   - severity: The severity of the error (defaults to the code's default severity)
    ///   - message: An optional custom message for the error
    ///   - underlyingError: The underlying error, if any
    ///   - timestamp: The timestamp when the error occurred (defaults to now)
    ///   - context: Additional context information for the error
    public init(
        id: String = UUID().uuidString,
        code: AppErrorCode,
        severity: ErrorSeverity? = nil,
        message: String? = nil,
        underlyingError: Error? = nil,
        timestamp: Date = Date(),
        context: [String: Any] = [:]
    ) {
        self.id = id
        self.code = code
        self.severity = severity ?? code.defaultSeverity
        self.message = message
        self.underlyingError = underlyingError
        self.timestamp = timestamp
        self.context = context
    }

    // MARK: - Equatable

    public static func == (lhs: AppError, rhs: AppError) -> Bool {
        return lhs.id == rhs.id
    }

    // MARK: - Convenience Methods

    /// Creates a new app error from an underlying error
    /// - Parameters:
    ///   - error: The underlying error
    ///   - code: The error code (defaults to .unknown)
    ///   - severity: The severity of the error (defaults to the code's default severity)
    ///   - message: An optional custom message for the error
    ///   - context: Additional context information for the error
    /// - Returns: A new app error
    public static func from(
        _ error: Error,
        code: AppErrorCode = .unknown,
        severity: ErrorSeverity? = nil,
        message: String? = nil,
        context: [String: Any] = [:]
    ) -> AppError {
        // If the error is already an AppError, return it with updated properties if provided
        if let appError = error as? AppError {
            return AppError(
                id: appError.id,
                code: code != .unknown ? code : appError.code,
                severity: severity ?? appError.severity,
                message: message ?? appError.message,
                underlyingError: appError.underlyingError,
                timestamp: appError.timestamp,
                context: context.isEmpty ? appError.context : context
            )
        }

        // Otherwise, create a new AppError with the provided error as the underlying error
        return AppError(
            code: code,
            severity: severity,
            message: message,
            underlyingError: error,
            context: context
        )
    }
}
