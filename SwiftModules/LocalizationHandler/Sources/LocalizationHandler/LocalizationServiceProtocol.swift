import Foundation

/// Protocol for localization service
public protocol LocalizationServiceProtocol {
    /// Gets a localized string for a key
    /// - Parameters:
    ///   - key: The key to get the localized string for
    ///   - defaultValue: The default value to return if the key is not found
    /// - Returns: The localized string
    func localizedString(forKey key: String, defaultValue: String?) -> String
    
    /// Gets a localized string for a key with arguments
    /// - Parameters:
    ///   - key: The key to get the localized string for
    ///   - arguments: The arguments to format the string with
    /// - Returns: The localized string
    func localizedString(forKey key: String, with arguments: [CVarArg]) -> String
    
    /// Gets the current language
    /// - Returns: The current language
    func currentLanguage() -> Language
    
    /// Sets the language
    /// - Parameter language: The language to set
    func setLanguage(_ language: Language)
    
    /// Gets a localized string for a key (shorthand method)
    /// - Parameter key: The key to get the localized string for
    /// - Returns: The localized string
    func localize(_ key: String) -> String
    
    /// Checks if the current language is right-to-left
    /// - Returns: True if the current language is right-to-left, false otherwise
    func isRightToLeft() -> Bool
    
    /// Gets all available languages
    /// - Returns: Array of available languages
    func availableLanguages() -> [Language]
}
