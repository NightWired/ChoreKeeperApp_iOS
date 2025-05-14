//
//  ErrorMiddleware.swift
//  ErrorHandler
//
//  Created on 2023-05-16.
//

import Foundation

/// Protocol for error middleware
/// Middleware can be used to intercept and process errors before they are handled
public protocol ErrorMiddleware {
    /// Process an error
    /// - Parameters:
    ///   - error: The error to process
    ///   - next: The next middleware in the chain
    func process(error: AppError, next: @escaping (AppError) -> Void)
}

/// Logging middleware for errors
public class LoggingMiddleware: ErrorMiddleware {
    // MARK: - Properties
    
    /// The log level for the middleware
    public enum LogLevel {
        /// Log all errors
        case all
        
        /// Log errors with severity medium and above
        case medium
        
        /// Log errors with severity high and above
        case high
        
        /// Log only critical errors
        case critical
    }
    
    /// The log level
    private let logLevel: LogLevel
    
    // MARK: - Initialization
    
    /// Creates a new logging middleware
    /// - Parameter logLevel: The log level (defaults to .all)
    public init(logLevel: LogLevel = .all) {
        self.logLevel = logLevel
    }
    
    // MARK: - ErrorMiddleware
    
    public func process(error: AppError, next: @escaping (AppError) -> Void) {
        // Check if the error should be logged based on the log level
        let shouldLog: Bool
        switch logLevel {
        case .all:
            shouldLog = true
        case .medium:
            shouldLog = error.severity != .low
        case .high:
            shouldLog = error.severity == .high || error.severity == .critical
        case .critical:
            shouldLog = error.severity == .critical
        }
        
        // Log the error if needed
        if shouldLog {
            let timestamp = ISO8601DateFormatter().string(from: error.timestamp)
            let message = error.message ?? "No message"
            let errorDescription = """
            [ERROR] [\(timestamp)] [\(error.formattedCode)] [\(error.severity.rawValue.uppercased())]
            Message: \(message)
            """
            
            // Print to console (in a real app, this would use a proper logging system)
            print(errorDescription)
            
            // If there's an underlying error, log it as well
            if let underlyingError = error.underlyingError {
                print("Underlying error: \(underlyingError)")
            }
            
            // Log context if available
            if !error.context.isEmpty {
                print("Context: \(error.context)")
            }
        }
        
        // Call the next middleware in the chain
        next(error)
    }
}

/// Analytics middleware for reporting errors to analytics services
public class AnalyticsMiddleware: ErrorMiddleware {
    // MARK: - Properties
    
    /// The analytics service
    private let analyticsService: AnalyticsService
    
    // MARK: - Initialization
    
    /// Creates a new analytics middleware
    /// - Parameter analyticsService: The analytics service to use
    public init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - ErrorMiddleware
    
    public func process(error: AppError, next: @escaping (AppError) -> Void) {
        // Only report errors that should be reported based on their severity
        if error.severity.shouldReport {
            // Report the error to the analytics service
            analyticsService.reportError(
                code: error.formattedCode,
                message: error.message ?? "No message",
                severity: error.severity.rawValue,
                timestamp: error.timestamp,
                context: error.context
            )
        }
        
        // Call the next middleware in the chain
        next(error)
    }
}

/// Protocol for analytics services
public protocol AnalyticsService {
    /// Report an error to the analytics service
    /// - Parameters:
    ///   - code: The error code
    ///   - message: The error message
    ///   - severity: The error severity
    ///   - timestamp: The timestamp when the error occurred
    ///   - context: Additional context information for the error
    func reportError(
        code: String,
        message: String,
        severity: String,
        timestamp: Date,
        context: [String: Any]
    )
}
