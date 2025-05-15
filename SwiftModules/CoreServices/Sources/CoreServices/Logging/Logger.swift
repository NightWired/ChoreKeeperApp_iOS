import Foundation
import LocalizationHandler
import ErrorHandler

/// Log level for the logger
public enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case critical = 4

    /// String representation of the log level
    public var description: String {
        switch self {
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .critical:
            return "CRITICAL"
        }
    }

    /// Localized string representation of the log level
    public var localizedDescription: String {
        switch self {
        case .debug:
            return LocalizationHandler.localize("logging.level.debug")
        case .info:
            return LocalizationHandler.localize("logging.level.info")
        case .warning:
            return LocalizationHandler.localize("logging.level.warning")
        case .error:
            return LocalizationHandler.localize("logging.level.error")
        case .critical:
            return LocalizationHandler.localize("logging.level.critical")
        }
    }

    /// Compare log levels
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// Protocol for log destinations
public protocol LogDestination {
    /// Log a message to the destination
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The log level
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line where the log was called
    ///   - context: Additional context for the log
    func log(message: String, level: LogLevel, file: String, function: String, line: Int, context: [String: Any]?)
}

/// Centralized logging system for the application
public final class Logger {

    // MARK: - Properties

    /// Shared instance of the logger
    private static let shared = Logger()

    /// The minimum log level to display
    private var minimumLogLevel: LogLevel = .debug

    /// Log destinations
    private var destinations: [LogDestination] = []

    /// Date formatter for log timestamps
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    /// Flag indicating whether the logger has been initialized
    private var isInitialized = false

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern
    private init() {}

    // MARK: - Public Methods

    /// Initialize the logger
    public static func initialize() {
        guard !shared.isInitialized else {
            return
        }

        // Add console destination by default
        addDestination(ConsoleLogDestination())

        // Set initialized flag
        shared.isInitialized = true
    }

    /// Reset the logger (primarily used for testing)
    public static func reset() {
        shared.destinations.removeAll()
        shared.minimumLogLevel = .debug
        shared.isInitialized = false
    }

    /// Set the minimum log level
    /// - Parameter level: The minimum log level to display
    public static func setMinimumLogLevel(_ level: LogLevel) {
        shared.minimumLogLevel = level
    }

    /// Add a log destination
    /// - Parameter destination: The destination to add
    public static func addDestination(_ destination: LogDestination) {
        shared.destinations.append(destination)
    }

    /// Remove all log destinations
    public static func removeAllDestinations() {
        shared.destinations.removeAll()
    }

    /// Log a debug message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line where the log was called
    ///   - context: Additional context for the log
    public static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line, context: [String: Any]? = nil) {
        shared.log(message: message, level: .debug, file: file, function: function, line: line, context: context)
    }

    /// Log an info message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line where the log was called
    ///   - context: Additional context for the log
    public static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line, context: [String: Any]? = nil) {
        shared.log(message: message, level: .info, file: file, function: function, line: line, context: context)
    }

    /// Log a warning message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line where the log was called
    ///   - context: Additional context for the log
    public static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line, context: [String: Any]? = nil) {
        shared.log(message: message, level: .warning, file: file, function: function, line: line, context: context)
    }

    /// Log an error message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line where the log was called
    ///   - context: Additional context for the log
    public static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line, context: [String: Any]? = nil) {
        shared.log(message: message, level: .error, file: file, function: function, line: line, context: context)
    }

    /// Log a critical message
    /// - Parameters:
    ///   - message: The message to log
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line where the log was called
    ///   - context: Additional context for the log
    public static func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line, context: [String: Any]? = nil) {
        shared.log(message: message, level: .critical, file: file, function: function, line: line, context: context)
    }

    /// Log an error
    /// - Parameters:
    ///   - error: The error to log
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line where the log was called
    ///   - context: Additional context for the log
    public static func log(error: Error, file: String = #file, function: String = #function, line: Int = #line, context: [String: Any]? = nil) {
        // Convert to AppError if needed
        let appError = error as? AppError ?? AppError.from(error)

        // Create context with error details
        var errorContext = context ?? [:]
        errorContext["errorCode"] = appError.formattedCode
        errorContext["errorSeverity"] = appError.severity.rawValue

        // Log the error
        shared.log(message: appError.message ?? error.localizedDescription, level: .error, file: file, function: function, line: line, context: errorContext)

        // Also handle the error with ErrorHandler
        ErrorHandler.handle(error)
    }

    // MARK: - Private Methods

    /// Log a message
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The log level
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line where the log was called
    ///   - context: Additional context for the log
    private func log(message: String, level: LogLevel, file: String, function: String, line: Int, context: [String: Any]?) {
        // Check if the log level is high enough
        guard level >= minimumLogLevel else {
            return
        }

        // Get the filename from the path
        let filename = URL(fileURLWithPath: file).lastPathComponent

        // Log to all destinations
        for destination in destinations {
            destination.log(message: message, level: level, file: filename, function: function, line: line, context: context)
        }
    }
}
