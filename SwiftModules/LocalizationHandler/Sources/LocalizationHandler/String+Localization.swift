import Foundation

/// Extension for String to add localization support
public extension String {
    /// Gets a localized string for this string as a key
    /// - Returns: The localized string
    func localized() -> String {
        return LocalizationService().localize(self)
    }
    
    /// Gets a localized string for this string as a key with arguments
    /// - Parameter arguments: The arguments to format the string with
    /// - Returns: The localized string
    func localized(with arguments: CVarArg...) -> String {
        let format = LocalizationService().localize(self)
        return String(format: format, arguments: arguments)
    }
}
