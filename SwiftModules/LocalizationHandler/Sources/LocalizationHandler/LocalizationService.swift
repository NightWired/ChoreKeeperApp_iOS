import Foundation

/// Implementation of the localization service
public class LocalizationService: LocalizationServiceProtocol {
    // MARK: - Properties

    /// Localization manager
    private let localizationManager: LocalizationManager

    // MARK: - Initialization

    /// Initializes a new instance of the localization service
    /// - Parameter localizationManager: The localization manager to use
    public init(localizationManager: LocalizationManager = .shared) {
        self.localizationManager = localizationManager
    }

    /// Registers a bundle for localization
    /// - Parameter bundle: The bundle to register
    public func registerBundle(_ bundle: Bundle) {
        localizationManager.registerBundle(bundle)
    }

    // MARK: - LocalizationServiceProtocol

    /// Gets a localized string for a key
    /// - Parameters:
    ///   - key: The key to get the localized string for
    ///   - defaultValue: The default value to return if the key is not found
    /// - Returns: The localized string
    public func localizedString(forKey key: String, defaultValue: String? = nil) -> String {
        return localizationManager.localizedStringForKeyPath(key, defaultValue: defaultValue)
    }

    /// Gets a localized string for a key with arguments
    /// - Parameters:
    ///   - key: The key to get the localized string for
    ///   - arguments: The arguments to format the string with
    /// - Returns: The localized string
    public func localizedString(forKey key: String, with arguments: [CVarArg]) -> String {
        let format = localizedString(forKey: key)
        return String(format: format, arguments: arguments)
    }

    /// Gets the current language
    /// - Returns: The current language
    public func currentLanguage() -> Language {
        return localizationManager.currentLanguage
    }

    /// Sets the language
    /// - Parameter language: The language to set
    public func setLanguage(_ language: Language) {
        localizationManager.currentLanguage = language
    }

    /// Gets a localized string for a key (shorthand method)
    /// - Parameter key: The key to get the localized string for
    /// - Returns: The localized string
    public func localize(_ key: String) -> String {
        return localizedString(forKey: key)
    }

    /// Checks if the current language is right-to-left
    /// - Returns: True if the current language is right-to-left, false otherwise
    public func isRightToLeft() -> Bool {
        return localizationManager.currentLanguage.isRightToLeft
    }

    /// Gets all available languages
    /// - Returns: Array of available languages
    public func availableLanguages() -> [Language] {
        return Language.allCases
    }
}
