import Foundation

/// Log destination that outputs to the console
public class ConsoleLogDestination: LogDestination {
    
    // MARK: - Properties
    
    /// Date formatter for log timestamps
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    // MARK: - Initialization
    
    /// Initialize a new console log destination
    public init() {}
    
    // MARK: - LogDestination
    
    /// Log a message to the console
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The log level
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line where the log was called
    ///   - context: Additional context for the log
    public func log(message: String, level: LogLevel, file: String, function: String, line: Int, context: [String: Any]?) {
        // Format the log message
        let timestamp = dateFormatter.string(from: Date())
        var logMessage = "[\(timestamp)] [\(level.description)] [\(file):\(line)] \(function): \(message)"
        
        // Add context if available
        if let context = context, !context.isEmpty {
            let contextString = context.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            logMessage += " - Context: {\(contextString)}"
        }
        
        // Print to console with appropriate color
        let coloredMessage = colorize(message: logMessage, for: level)
        print(coloredMessage)
    }
    
    // MARK: - Private Methods
    
    /// Add color to a log message based on the log level
    /// - Parameters:
    ///   - message: The message to colorize
    ///   - level: The log level
    /// - Returns: The colorized message
    private func colorize(message: String, for level: LogLevel) -> String {
        // ANSI color codes
        let reset = "\u{001B}[0m"
        let color: String
        
        switch level {
        case .debug:
            color = "\u{001B}[37m" // White
        case .info:
            color = "\u{001B}[32m" // Green
        case .warning:
            color = "\u{001B}[33m" // Yellow
        case .error:
            color = "\u{001B}[31m" // Red
        case .critical:
            color = "\u{001B}[35m" // Magenta
        }
        
        return color + message + reset
    }
}
