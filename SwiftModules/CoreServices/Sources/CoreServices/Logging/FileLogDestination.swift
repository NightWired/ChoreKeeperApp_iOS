import Foundation

/// Log destination that outputs to a file
public class FileLogDestination: LogDestination {
    
    // MARK: - Properties
    
    /// The URL of the log file
    private let fileURL: URL
    
    /// Date formatter for log timestamps
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    /// File manager for file operations
    private let fileManager = FileManager.default
    
    /// Maximum file size in bytes (default: 10MB)
    private let maxFileSize: UInt64
    
    /// Maximum number of backup log files (default: 5)
    private let maxBackupCount: Int
    
    /// Queue for file operations
    private let queue = DispatchQueue(label: "com.chorekeeper.coreservices.filelogdestination", qos: .utility)
    
    // MARK: - Initialization
    
    /// Initialize a new file log destination
    /// - Parameters:
    ///   - fileURL: The URL of the log file
    ///   - maxFileSize: Maximum file size in bytes (default: 10MB)
    ///   - maxBackupCount: Maximum number of backup log files (default: 5)
    public init(fileURL: URL, maxFileSize: UInt64 = 10_485_760, maxBackupCount: Int = 5) {
        self.fileURL = fileURL
        self.maxFileSize = maxFileSize
        self.maxBackupCount = maxBackupCount
        
        // Create the log directory if it doesn't exist
        createLogDirectory()
    }
    
    // MARK: - LogDestination
    
    /// Log a message to the file
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The log level
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line where the log was called
    ///   - context: Additional context for the log
    public func log(message: String, level: LogLevel, file: String, function: String, line: Int, context: [String: Any]?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // Format the log message
            let timestamp = self.dateFormatter.string(from: Date())
            var logMessage = "[\(timestamp)] [\(level.description)] [\(file):\(line)] \(function): \(message)"
            
            // Add context if available
            if let context = context, !context.isEmpty {
                let contextString = context.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
                logMessage += " - Context: {\(contextString)}"
            }
            
            // Add newline
            logMessage += "\n"
            
            // Check if the file needs to be rotated
            self.rotateFileIfNeeded()
            
            // Write to the file
            self.writeToFile(logMessage)
        }
    }
    
    // MARK: - Private Methods
    
    /// Create the log directory if it doesn't exist
    private func createLogDirectory() {
        let directory = fileURL.deletingLastPathComponent()
        
        if !fileManager.fileExists(atPath: directory.path) {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating log directory: \(error.localizedDescription)")
            }
        }
    }
    
    /// Write a message to the log file
    /// - Parameter message: The message to write
    private func writeToFile(_ message: String) {
        do {
            // Create the file if it doesn't exist
            if !fileManager.fileExists(atPath: fileURL.path) {
                fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
            }
            
            // Get file handle for appending
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            
            // Seek to end of file
            fileHandle.seekToEndOfFile()
            
            // Write the message
            if let data = message.data(using: .utf8) {
                fileHandle.write(data)
            }
            
            // Close the file
            fileHandle.closeFile()
        } catch {
            print("Error writing to log file: \(error.localizedDescription)")
        }
    }
    
    /// Check if the file needs to be rotated and rotate it if necessary
    private func rotateFileIfNeeded() {
        do {
            // Check if the file exists
            guard fileManager.fileExists(atPath: fileURL.path) else {
                return
            }
            
            // Get file attributes
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            
            // Get file size
            guard let fileSize = attributes[.size] as? UInt64 else {
                return
            }
            
            // Check if the file size exceeds the maximum
            if fileSize > maxFileSize {
                rotateLogFile()
            }
        } catch {
            print("Error checking log file size: \(error.localizedDescription)")
        }
    }
    
    /// Rotate the log file
    private func rotateLogFile() {
        do {
            // Remove the oldest backup if it exists
            let oldestBackupURL = fileURL.appendingPathExtension("\(maxBackupCount)")
            if fileManager.fileExists(atPath: oldestBackupURL.path) {
                try fileManager.removeItem(at: oldestBackupURL)
            }
            
            // Shift existing backups
            for i in stride(from: maxBackupCount - 1, through: 1, by: -1) {
                let currentBackupURL = fileURL.appendingPathExtension("\(i)")
                let newBackupURL = fileURL.appendingPathExtension("\(i + 1)")
                
                if fileManager.fileExists(atPath: currentBackupURL.path) {
                    try fileManager.moveItem(at: currentBackupURL, to: newBackupURL)
                }
            }
            
            // Move the current log file to backup 1
            let firstBackupURL = fileURL.appendingPathExtension("1")
            try fileManager.moveItem(at: fileURL, to: firstBackupURL)
            
            // Create a new log file
            fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        } catch {
            print("Error rotating log file: \(error.localizedDescription)")
        }
    }
}
