import Foundation
import LocalizationHandler

/// Extensions for String
public extension String {
    
    /// Localize a string using the LocalizationHandler
    var localized: String {
        return LocalizationHandler.localize(self)
    }
    
    /// Check if the string is empty or contains only whitespace
    var isEmptyOrWhitespace: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Check if the string is a valid email address
    var isValidEmail: Bool {
        return StringUtilities.isValidEmail(self)
    }
    
    /// Check if the string is a valid URL
    var isValidURL: Bool {
        return StringUtilities.isValidURL(self)
    }
    
    /// Check if the string is a valid phone number
    var isValidPhoneNumber: Bool {
        return StringUtilities.isValidPhoneNumber(self)
    }
    
    /// Convert the string to camel case
    var camelCased: String {
        return StringUtilities.camelCase(self)
    }
    
    /// Convert the string to snake case
    var snakeCased: String {
        return StringUtilities.snakeCase(self)
    }
    
    /// Convert the string to kebab case
    var kebabCased: String {
        return StringUtilities.kebabCase(self)
    }
    
    /// Slugify the string
    var slugified: String {
        return StringUtilities.slugify(self)
    }
    
    /// Compute the SHA-256 hash of the string
    var sha256: String {
        return SecurityUtilities.sha256(self)
    }
    
    /// Truncate the string to a maximum length
    /// - Parameters:
    ///   - maxLength: The maximum length
    ///   - trailing: The trailing string to add if truncated (default: "...")
    /// - Returns: The truncated string
    func truncated(to maxLength: Int, trailing: String = "...") -> String {
        return StringUtilities.truncate(self, maxLength: maxLength, trailing: trailing)
    }
    
    /// Format the string with named placeholders
    /// - Parameter arguments: The arguments to replace the placeholders
    /// - Returns: The formatted string
    func format(with arguments: [String: String]) -> String {
        return StringUtilities.format(self, arguments: arguments)
    }
    
    /// Format the string with positional placeholders
    /// - Parameter arguments: The arguments to replace the placeholders
    /// - Returns: The formatted string
    func format(_ arguments: String...) -> String {
        return StringUtilities.format(self, arguments.joined())
    }
    
    /// Get a substring with a range
    /// - Parameter range: The range
    /// - Returns: The substring
    subscript(range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    /// Get a substring with a closed range
    /// - Parameter range: The range
    /// - Returns: The substring
    subscript(range: ClosedRange<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[startIndex...endIndex])
    }
    
    /// Get a substring from a start index to the end
    /// - Parameter start: The start index
    /// - Returns: The substring
    subscript(from start: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: start)
        return String(self[startIndex...])
    }
    
    /// Get a substring from the start to an end index
    /// - Parameter end: The end index
    /// - Returns: The substring
    subscript(to end: Int) -> String {
        let endIndex = self.index(self.startIndex, offsetBy: end)
        return String(self[..<endIndex])
    }
    
    /// Get a character at an index
    /// - Parameter index: The index
    /// - Returns: The character
    subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
