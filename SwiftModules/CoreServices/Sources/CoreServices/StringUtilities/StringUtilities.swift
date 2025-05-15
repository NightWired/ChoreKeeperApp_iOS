import Foundation

/// Utilities for working with strings
public struct StringUtilities {
    
    // MARK: - Validation
    
    /// Check if a string is a valid email address
    /// - Parameter email: The email address to check
    /// - Returns: True if valid, false otherwise
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Check if a string is a valid URL
    /// - Parameter urlString: The URL string to check
    /// - Returns: True if valid, false otherwise
    public static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        
        return url.scheme != nil && url.host != nil
    }
    
    /// Check if a string is a valid phone number
    /// - Parameter phoneNumber: The phone number to check
    /// - Returns: True if valid, false otherwise
    public static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^[+]?[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    /// Check if a string is empty or whitespace
    /// - Parameter string: The string to check
    /// - Returns: True if empty or whitespace, false otherwise
    public static func isEmptyOrWhitespace(_ string: String) -> Bool {
        return string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Transformation
    
    /// Convert a string to camel case
    /// - Parameter string: The string to convert
    /// - Returns: The camel case string
    public static func camelCase(_ string: String) -> String {
        let words = string.components(separatedBy: .whitespacesAndNewlines)
        guard let firstWord = words.first else {
            return string
        }
        
        let firstWordLower = firstWord.lowercased()
        let otherWords = words.dropFirst().map { $0.capitalized }
        
        return ([firstWordLower] + otherWords).joined()
    }
    
    /// Convert a string to snake case
    /// - Parameter string: The string to convert
    /// - Returns: The snake case string
    public static func snakeCase(_ string: String) -> String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: string.utf16.count)
        var result = regex?.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "$1_$2") ?? string
        
        result = result.replacingOccurrences(of: " ", with: "_")
        return result.lowercased()
    }
    
    /// Convert a string to kebab case
    /// - Parameter string: The string to convert
    /// - Returns: The kebab case string
    public static func kebabCase(_ string: String) -> String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: string.utf16.count)
        var result = regex?.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "$1-$2") ?? string
        
        result = result.replacingOccurrences(of: " ", with: "-")
        return result.lowercased()
    }
    
    /// Slugify a string (convert to lowercase, replace spaces with hyphens, remove special characters)
    /// - Parameter string: The string to slugify
    /// - Returns: The slugified string
    public static func slugify(_ string: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        let lowercased = string.lowercased()
        let withDashes = lowercased.replacingOccurrences(of: " ", with: "-")
        
        return withDashes.components(separatedBy: allowedCharacters.inverted).joined()
    }
    
    /// Truncate a string to a maximum length
    /// - Parameters:
    ///   - string: The string to truncate
    ///   - maxLength: The maximum length
    ///   - trailing: The trailing string to add if truncated (default: "...")
    /// - Returns: The truncated string
    public static func truncate(_ string: String, maxLength: Int, trailing: String = "...") -> String {
        guard string.count > maxLength else {
            return string
        }
        
        let truncated = string.prefix(maxLength)
        return String(truncated) + trailing
    }
    
    // MARK: - Regular Expressions
    
    /// Check if a string matches a regular expression
    /// - Parameters:
    ///   - string: The string to check
    ///   - pattern: The regular expression pattern
    /// - Returns: True if the string matches the pattern, false otherwise
    public static func matches(_ string: String, pattern: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: string)
    }
    
    /// Extract substrings matching a regular expression
    /// - Parameters:
    ///   - string: The string to search
    ///   - pattern: The regular expression pattern
    /// - Returns: An array of matching substrings
    public static func extract(_ string: String, pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: string) else {
                return nil
            }
            
            return String(string[range])
        }
    }
    
    /// Replace substrings matching a regular expression
    /// - Parameters:
    ///   - string: The string to modify
    ///   - pattern: The regular expression pattern
    ///   - replacement: The replacement string
    /// - Returns: The modified string
    public static func replace(_ string: String, pattern: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return string
        }
        
        let range = NSRange(location: 0, length: string.utf16.count)
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: replacement)
    }
    
    // MARK: - Formatting
    
    /// Format a string with named placeholders
    /// - Parameters:
    ///   - format: The format string with placeholders in the form {name}
    ///   - arguments: The arguments to replace the placeholders
    /// - Returns: The formatted string
    public static func format(_ format: String, arguments: [String: String]) -> String {
        var result = format
        
        for (key, value) in arguments {
            result = result.replacingOccurrences(of: "{\(key)}", with: value)
        }
        
        return result
    }
    
    /// Format a string with positional placeholders
    /// - Parameters:
    ///   - format: The format string with placeholders in the form {}
    ///   - arguments: The arguments to replace the placeholders
    /// - Returns: The formatted string
    public static func format(_ format: String, _ arguments: String...) -> String {
        var result = format
        var index = 0
        
        while let range = result.range(of: "{}") {
            guard index < arguments.count else {
                break
            }
            
            result.replaceSubrange(range, with: arguments[index])
            index += 1
        }
        
        return result
    }
}
