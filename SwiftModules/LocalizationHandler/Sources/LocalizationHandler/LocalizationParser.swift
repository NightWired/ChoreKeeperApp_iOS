import Foundation

/// Parser for localization files
public class LocalizationParser {
    // MARK: - Properties

    /// File manager
    private let fileManager = FileManager.default

    // MARK: - Initialization

    /// Initializes a new instance of the localization parser
    public init() {}

    // MARK: - Methods

    /// Parses a localization file
    /// - Parameters:
    ///   - url: The URL of the file to parse
    /// - Returns: The parsed localization data, or nil if the file could not be parsed
    public func parseFile(at url: URL) -> [String: Any]? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        return parseData(data)
    }

    /// Parses localization data
    /// - Parameter data: The data to parse
    /// - Returns: The parsed localization data, or nil if the data could not be parsed
    public func parseData(_ data: Data) -> [String: Any]? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return json
            }
        } catch {
            print("Error parsing localization data: \(error)")
        }

        return nil
    }

    /// Gets the localization file URL for a language
    /// - Parameters:
    ///   - language: The language to get the file for
    ///   - baseURL: The base URL for localization files
    /// - Returns: The URL of the localization file, or nil if the file does not exist
    public func localizationFileURL(for language: Language, baseURL: URL) -> URL? {
        // First try the standard path: baseURL/language/language.json
        let languageURL = baseURL.appendingPathComponent(language.rawValue)
        let fileURL = languageURL.appendingPathComponent("\(language.rawValue).json")

        print("Checking for localization file at: \(fileURL.path)")
        if fileManager.fileExists(atPath: fileURL.path) {
            print("Found localization file at: \(fileURL.path)")
            return fileURL
        }

        // Fallback to check for Localizable.json (for backward compatibility)
        let fallbackURL = languageURL.appendingPathComponent("Localizable.json")
        print("Checking for fallback localization file at: \(fallbackURL.path)")
        if fileManager.fileExists(atPath: fallbackURL.path) {
            print("Found fallback localization file at: \(fallbackURL.path)")
            return fallbackURL
        }

        // Try direct JSON file in the language directory
        let directURL = baseURL.appendingPathComponent("\(language.rawValue).json")
        print("Checking for direct localization file at: \(directURL.path)")
        if fileManager.fileExists(atPath: directURL.path) {
            print("Found direct localization file at: \(directURL.path)")
            return directURL
        }

        print("No localization file found for language: \(language.rawValue)")
        return nil
    }

    /// Gets the value for a key path in a dictionary
    /// - Parameters:
    ///   - keyPath: The key path to get the value for
    ///   - dictionary: The dictionary to get the value from
    /// - Returns: The value, or nil if the key path is not found
    public func value(for keyPath: String, in dictionary: [String: Any]) -> Any? {
        let keys = keyPath.components(separatedBy: ".")
        var currentDict = dictionary

        for (index, key) in keys.enumerated() {
            if index == keys.count - 1 {
                // Last key, return the value
                return currentDict[key]
            } else {
                // Not the last key, navigate to the next level
                if let dict = currentDict[key] as? [String: Any] {
                    currentDict = dict
                } else {
                    return nil
                }
            }
        }

        return nil
    }
}
