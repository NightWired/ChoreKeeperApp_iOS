import Foundation

/// Language enum representing all supported languages in the application
public enum Language: String, CaseIterable, Identifiable, Codable {
    // MARK: - Cases
    
    /// English
    case english = "en"
    
    /// Spanish
    case spanish = "es"
    
    /// French
    case french = "fr"
    
    /// German
    case german = "de"
    
    /// Italian
    case italian = "it"
    
    /// Portuguese
    case portuguese = "pt"
    
    /// Russian
    case russian = "ru"
    
    /// Chinese
    case chinese = "zh"
    
    /// Japanese
    case japanese = "ja"
    
    /// Korean
    case korean = "ko"
    
    /// Arabic
    case arabic = "ar"
    
    /// Hindi
    case hindi = "hi"
    
    /// Dutch
    case dutch = "nl"
    
    /// Polish
    case polish = "pl"
    
    /// Swedish
    case swedish = "sv"
    
    /// Turkish
    case turkish = "tr"
    
    /// Vietnamese
    case vietnamese = "vi"
    
    // MARK: - Properties
    
    /// The language ID
    public var id: String {
        return rawValue
    }
    
    /// The language name in its native form
    public var name: String {
        switch self {
        case .english:
            return "English"
        case .spanish:
            return "Español"
        case .french:
            return "Français"
        case .german:
            return "Deutsch"
        case .italian:
            return "Italiano"
        case .portuguese:
            return "Português"
        case .russian:
            return "Русский"
        case .chinese:
            return "中文"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .arabic:
            return "العربية"
        case .hindi:
            return "हिन्दी"
        case .dutch:
            return "Nederlands"
        case .polish:
            return "Polski"
        case .swedish:
            return "Svenska"
        case .turkish:
            return "Türkçe"
        case .vietnamese:
            return "Tiếng Việt"
        }
    }
    
    /// The flag emoji representing the language
    public var flag: String {
        switch self {
        case .english:
            return "🇺🇸"
        case .spanish:
            return "🇪🇸"
        case .french:
            return "🇫🇷"
        case .german:
            return "🇩🇪"
        case .italian:
            return "🇮🇹"
        case .portuguese:
            return "🇵🇹"
        case .russian:
            return "🇷🇺"
        case .chinese:
            return "🇨🇳"
        case .japanese:
            return "🇯🇵"
        case .korean:
            return "🇰🇷"
        case .arabic:
            return "🇸🇦"
        case .hindi:
            return "🇮🇳"
        case .dutch:
            return "🇳🇱"
        case .polish:
            return "🇵🇱"
        case .swedish:
            return "🇸🇪"
        case .turkish:
            return "🇹🇷"
        case .vietnamese:
            return "🇻🇳"
        }
    }
    
    /// The display name (flag + name)
    public var displayName: String {
        return "\(flag) \(name)"
    }
    
    /// Indicates if the language is right-to-left
    public var isRightToLeft: Bool {
        return self == .arabic
    }
    
    // MARK: - Methods
    
    /// Creates a language from a locale identifier
    /// - Parameter localeIdentifier: The locale identifier
    /// - Returns: The language, or nil if not found
    public static func from(localeIdentifier: String) -> Language? {
        return Language.allCases.first { $0.rawValue == localeIdentifier }
    }
    
    /// Gets the device language
    /// - Returns: The device language, or English if not found
    public static func deviceLanguage() -> Language {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let languageCode = Locale(identifier: preferredLanguage).languageCode ?? "en"
        return Language.from(localeIdentifier: languageCode) ?? .english
    }
}
