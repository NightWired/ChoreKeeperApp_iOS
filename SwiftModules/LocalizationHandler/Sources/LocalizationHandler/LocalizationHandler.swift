import Foundation

/// Main entry point for the localization handler
public struct LocalizationHandler {
    // MARK: - Properties

    /// Shared instance of the localization service
    public static let shared = LocalizationService()

    // MARK: - Initialization

    /// Private initializer to prevent direct instantiation
    private init() {}

    // MARK: - Methods

    /// Gets a localized string for a key
    /// - Parameter key: The key to get the localized string for
    /// - Returns: The localized string
    public static func localize(_ key: String) -> String {
        return shared.localize(key)
    }

    /// Gets a localized string for a key with arguments
    /// - Parameters:
    ///   - key: The key to get the localized string for
    ///   - arguments: The arguments to format the string with
    /// - Returns: The localized string
    public static func localize(_ key: String, with arguments: CVarArg...) -> String {
        return shared.localizedString(forKey: key, with: arguments)
    }

    /// Gets the current language
    /// - Returns: The current language
    public static func currentLanguage() -> Language {
        return shared.currentLanguage()
    }

    /// Sets the language
    /// - Parameter language: The language to set
    public static func setLanguage(_ language: Language) {
        shared.setLanguage(language)
    }

    /// Registers a bundle for localization
    /// - Parameter bundle: The bundle to register
    public static func registerBundle(_ bundle: Bundle) {
        shared.registerBundle(bundle)
    }

    /// Checks if the current language is right-to-left
    /// - Returns: True if the current language is right-to-left, false otherwise
    public static func isRightToLeft() -> Bool {
        return shared.isRightToLeft()
    }

    /// Gets all available languages
    /// - Returns: Array of available languages
    public static func availableLanguages() -> [Language] {
        return shared.availableLanguages()
    }

    /// Debug method to check if localization files are properly loaded
    /// - Returns: Information about the localization files
    public static func debugLocalizationInfo() -> String {
        let language = currentLanguage()
        let appName = localize("app.name")
        let welcomeTitle = localize("onboarding.welcome.title")

        // Check if the main bundle contains the localization files
        var bundleInfo = "Bundle paths:\n"
        if let bundleURL = Bundle.main.resourceURL {
            bundleInfo += "- Bundle URL: \(bundleURL.path)\n"

            let localizationAssetsURL = bundleURL.appendingPathComponent("LocalizationAssets")
            bundleInfo += "- LocalizationAssets URL: \(localizationAssetsURL.path)\n"

            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: localizationAssetsURL.path) {
                bundleInfo += "  - Directory exists\n"

                let languageURL = localizationAssetsURL.appendingPathComponent(language.rawValue)
                bundleInfo += "  - Language directory: \(languageURL.path)\n"

                if fileManager.fileExists(atPath: languageURL.path) {
                    bundleInfo += "    - Language directory exists\n"

                    let fileURL = languageURL.appendingPathComponent("\(language.rawValue).json")
                    bundleInfo += "    - Language file: \(fileURL.path)\n"

                    if fileManager.fileExists(atPath: fileURL.path) {
                        bundleInfo += "      - Language file exists\n"
                    } else {
                        bundleInfo += "      - Language file does not exist\n"
                    }
                } else {
                    bundleInfo += "    - Language directory does not exist\n"
                }
            } else {
                bundleInfo += "  - Directory does not exist\n"
            }
        }

        // Check if we can find the file using bundle resource lookup
        if let bundlePath = Bundle.main.path(forResource: language.rawValue, ofType: "json", inDirectory: "LocalizationAssets/\(language.rawValue)") {
            bundleInfo += "- Found using resource lookup: \(bundlePath)\n"
        } else {
            bundleInfo += "- Not found using resource lookup\n"
        }

        return """
        Localization Debug Info:
        - Current language: \(language.name) (\(language.rawValue))
        - Localized app.name: \(appName)
        - Localized welcome title: \(welcomeTitle)

        \(bundleInfo)
        """
    }
}
