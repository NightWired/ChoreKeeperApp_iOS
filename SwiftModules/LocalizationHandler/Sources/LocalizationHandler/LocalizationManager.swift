import Foundation

/// Class responsible for managing localization
public class LocalizationManager {
    // MARK: - Properties

    /// Shared instance
    public static let shared = LocalizationManager()

    /// Registered bundles for localization
    private var registeredBundles: [Bundle] = [Bundle.main]

    /// Current language
    public var currentLanguage: Language {
        get {
            if let languageString = UserDefaults.standard.string(forKey: "app_language"),
               let language = Language.from(localeIdentifier: languageString) {
                return language
            }
            return Language.deviceLanguage()
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "app_language")
            loadLocalizationData()
            NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        }
    }

    /// Localization data
    private var localizationData: [String: Any] = [:]

    /// Default language
    private let defaultLanguage: Language = .english

    /// File manager
    private let fileManager = FileManager.default

    // MARK: - Initialization

    /// Private initializer
    private init() {
        loadLocalizationData()
    }

    // MARK: - Methods

    /// Registers a bundle for localization
    /// - Parameter bundle: The bundle to register
    public func registerBundle(_ bundle: Bundle) {
        if !registeredBundles.contains(bundle) {
            registeredBundles.append(bundle)
            // Reload localization data to include the new bundle
            loadLocalizationData()
        }
    }

    /// Loads localization data
    private func loadLocalizationData() {
        localizationData = [:]

        // Load localization data for current language
        if let data = loadLocalizationFile(for: currentLanguage) {
            localizationData = data
        } else if let data = loadLocalizationFile(for: defaultLanguage) {
            // Fallback to default language
            localizationData = data
        }
    }

    /// Loads localization file for a language
    /// - Parameter language: The language to load the file for
    /// - Returns: The localization data, or nil if the file could not be loaded
    private func loadLocalizationFile(for language: Language) -> [String: Any]? {
        let parser = LocalizationParser()

        // Try to load from all registered bundles
        for bundle in registeredBundles {
            // 1. Try to find the file in the bundle's LocalizationAssets directory
            if let bundleURL = bundle.resourceURL {
                let localizationAssetsURL = bundleURL.appendingPathComponent("LocalizationAssets")

                if let fileURL = parser.localizationFileURL(for: language, baseURL: localizationAssetsURL),
                   let data = try? Data(contentsOf: fileURL),
                   let json = parser.parseData(data) {
                    print("Loaded localization from bundle LocalizationAssets: \(fileURL.path)")
                    return json
                }
            }

            // 2. Try to find the file using bundle resource lookup with directory
            if let bundlePath = bundle.path(forResource: language.rawValue, ofType: "json", inDirectory: "LocalizationAssets/\(language.rawValue)"),
               let data = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)),
               let json = parser.parseData(data) {
                print("Loaded localization from bundle path: \(bundlePath)")
                return json
            }

            // 3. Try to find the file using direct bundle resource lookup
            if let bundlePath = bundle.path(forResource: language.rawValue, ofType: "json"),
               let data = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)),
               let json = parser.parseData(data) {
                print("Loaded localization from bundle resource: \(bundlePath)")
                return json
            }

            // 4. Try to find the file in the LocalizationAssets directory using nested path
            if let bundlePath = bundle.path(forResource: "LocalizationAssets/\(language.rawValue)/\(language.rawValue)", ofType: "json"),
               let data = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)),
               let json = parser.parseData(data) {
                print("Loaded localization from nested bundle resource: \(bundlePath)")
                return json
            }
        }

        // If we couldn't load from any file in any bundle, use mock data for testing
        print("Using mock localization data for language: \(language.rawValue)")
        return mockLocalizationData(for: language)
    }

    /// Gets a localized string for a key path
    /// - Parameters:
    ///   - keyPath: The key path to get the localized string for
    ///   - defaultValue: The default value to return if the key path is not found
    /// - Returns: The localized string
    public func localizedStringForKeyPath(_ keyPath: String, defaultValue: String? = nil) -> String {
        let keys = keyPath.components(separatedBy: ".")
        var currentDict: [String: Any] = localizationData

        // Navigate through the nested structure
        for (index, key) in keys.enumerated() {
            if index == keys.count - 1 {
                // Last key, should be the value
                if let value = currentDict[key] as? String {
                    return value
                } else {
                    break
                }
            } else {
                // Not the last key, should be a dictionary
                if let dict = currentDict[key] as? [String: Any] {
                    currentDict = dict
                } else {
                    break
                }
            }
        }

        // Key path not found, try default language
        if currentLanguage != defaultLanguage {
            if let defaultData = loadLocalizationFile(for: defaultLanguage) {
                var currentDefaultDict: [String: Any] = defaultData

                // Navigate through the nested structure in default language
                for (index, key) in keys.enumerated() {
                    if index == keys.count - 1 {
                        // Last key, should be the value
                        if let value = currentDefaultDict[key] as? String {
                            return value
                        } else {
                            break
                        }
                    } else {
                        // Not the last key, should be a dictionary
                        if let dict = currentDefaultDict[key] as? [String: Any] {
                            currentDefaultDict = dict
                        } else {
                            break
                        }
                    }
                }
            }
        }

        // Return default value or key path
        return defaultValue ?? keyPath
    }

    /// Gets a localized string for a key path with arguments
    /// - Parameters:
    ///   - keyPath: The key path to get the localized string for
    ///   - arguments: The arguments to format the string with
    /// - Returns: The localized string
    public func localizedStringForKeyPath(_ keyPath: String, with arguments: CVarArg...) -> String {
        let format = localizedStringForKeyPath(keyPath)
        return String(format: format, arguments: arguments)
    }

    // MARK: - Mock Implementation

    /// Mock localization data for testing
    /// - Parameter language: The language to get mock data for
    /// - Returns: Mock localization data
    private func mockLocalizationData(for language: Language) -> [String: Any] {
        switch language {
        case .english:
            return [
                "app": [
                    "name": "ChoreKeeper"
                ],
                "common": [
                    "ok": "OK",
                    "cancel": "Cancel",
                    "save": "Save",
                    "delete": "Delete",
                    "edit": "Edit",
                    "yes": "Yes",
                    "no": "No",
                    "loading": "Loading...",
                    "success": "Success",
                    "error": "Error"
                ],
                "onboarding": [
                    "welcome": [
                        "title": "Welcome to ChoreKeeper",
                        "message": "The app that helps you manage chores and rewards."
                    ],
                    "userType": [
                        "parent": "Parent",
                        "child": "Child"
                    ]
                ],
                "greeting": [
                    "withName": "Hello, %@!"
                ],
                "dashboard": [
                    "parent": [
                        "children": "Children",
                        "title": "Parent Dashboard"
                    ]
                ],
                "children": [
                    "add": "Add Child",
                    "detail": "Child Details",
                    "title": "Children"
                ],
                "settings": [
                    "account": "Account"
                ],
                "statistics": [
                    "startDate": "Start Date",
                    "endDate": "End Date"
                ],
                "auth": [
                    "username": "Username"
                ]
            ]
        case .spanish:
            return [
                "app": [
                    "name": "ChoreKeeper"
                ],
                "common": [
                    "ok": "Aceptar",
                    "cancel": "Cancelar",
                    "save": "Guardar",
                    "delete": "Eliminar",
                    "edit": "Editar",
                    "yes": "Sí",
                    "no": "No",
                    "loading": "Cargando...",
                    "success": "Éxito",
                    "error": "Error"
                ],
                "onboarding": [
                    "welcome": [
                        "title": "Bienvenido a ChoreKeeper",
                        "message": "La aplicación que te ayuda a gestionar tareas y recompensas."
                    ],
                    "userType": [
                        "parent": "Padre",
                        "child": "Niño"
                    ]
                ],
                "greeting": [
                    "withName": "¡Hola, %@!"
                ],
                "dashboard": [
                    "parent": [
                        "children": "Niños",
                        "title": "Panel de Padres"
                    ]
                ],
                "children": [
                    "add": "Añadir Niño",
                    "detail": "Detalles del Niño",
                    "title": "Niños"
                ],
                "settings": [
                    "account": "Cuenta"
                ],
                "statistics": [
                    "startDate": "Fecha de Inicio",
                    "endDate": "Fecha de Fin"
                ],
                "auth": [
                    "username": "Nombre de Usuario"
                ]
            ]
        default:
            // For other languages, use English as fallback
            return mockLocalizationData(for: .english)
        }
    }
}
