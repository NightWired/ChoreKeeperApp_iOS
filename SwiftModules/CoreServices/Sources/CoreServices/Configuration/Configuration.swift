import Foundation
import LocalizationHandler
import ErrorHandler

/// Environment type for configuration
public enum Environment: String {
    case development
    case staging
    case production
    case testing
    
    /// String representation of the environment
    public var description: String {
        return rawValue.capitalized
    }
    
    /// Localized string representation of the environment
    public var localizedDescription: String {
        switch self {
        case .development:
            return LocalizationHandler.localize("environment.development")
        case .staging:
            return LocalizationHandler.localize("environment.staging")
        case .production:
            return LocalizationHandler.localize("environment.production")
        case .testing:
            return LocalizationHandler.localize("environment.testing")
        }
    }
}

/// Configuration error types
public enum ConfigurationError: Error {
    case notInitialized
    case invalidKey(String)
    case invalidValue(String, Any)
    case missingRequiredValue(String)
}

/// Configuration manager for the application
public final class Configuration {
    
    // MARK: - Properties
    
    /// Shared instance of the configuration
    public static let shared = Configuration()
    
    /// Configuration values
    private var values: [String: Any] = [:]
    
    /// Feature flags
    private var featureFlags: [String: Bool] = [:]
    
    /// Current environment
    private var environment: Environment = .development
    
    /// Flag indicating whether the configuration has been initialized
    private var isInitialized = false
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    // MARK: - Public Methods
    
    /// Initialize the configuration with values
    /// - Parameter values: The configuration values
    public func initialize(with values: [String: Any]) {
        self.values = values
        
        // Extract environment if provided
        if let environmentString = values["environment"] as? String,
           let environment = Environment(rawValue: environmentString) {
            self.environment = environment
        }
        
        // Extract feature flags if provided
        if let featureFlags = values["featureFlags"] as? [String: Bool] {
            self.featureFlags = featureFlags
        }
        
        isInitialized = true
    }
    
    /// Reset the configuration (primarily used for testing)
    public func reset() {
        values.removeAll()
        featureFlags.removeAll()
        environment = .development
        isInitialized = false
    }
    
    /// Get the current environment
    /// - Returns: The current environment
    public func getEnvironment() -> Environment {
        return environment
    }
    
    /// Set the current environment
    /// - Parameter environment: The environment to set
    public func setEnvironment(_ environment: Environment) {
        self.environment = environment
    }
    
    /// Check if the configuration has been initialized
    /// - Returns: True if initialized, false otherwise
    public func isConfigured() -> Bool {
        return isInitialized
    }
    
    /// Get a configuration value
    /// - Parameter key: The key to get the value for
    /// - Returns: The value if found, nil otherwise
    public func getValue<T>(for key: String) -> T? {
        guard isInitialized else {
            Logger.error("Configuration not initialized")
            return nil
        }
        
        return values[key] as? T
    }
    
    /// Get a required configuration value
    /// - Parameter key: The key to get the value for
    /// - Returns: The value
    /// - Throws: ConfigurationError if the value is not found or is of the wrong type
    public func getRequiredValue<T>(for key: String) throws -> T {
        guard isInitialized else {
            throw ConfigurationError.notInitialized
        }
        
        guard let value = values[key] else {
            throw ConfigurationError.invalidKey(key)
        }
        
        guard let typedValue = value as? T else {
            throw ConfigurationError.invalidValue(key, value)
        }
        
        return typedValue
    }
    
    /// Register a configuration value
    /// - Parameters:
    ///   - value: The value to register
    ///   - key: The key to register the value for
    public func register<T>(value: T, for key: String) {
        values[key] = value
    }
    
    /// Check if a feature is enabled
    /// - Parameter feature: The feature to check
    /// - Returns: True if the feature is enabled, false otherwise
    public func isFeatureEnabled(_ feature: String) -> Bool {
        return featureFlags[feature] ?? false
    }
    
    /// Register a feature flag
    /// - Parameters:
    ///   - name: The name of the feature
    ///   - isEnabled: Whether the feature is enabled
    public func registerFeature(name: String, isEnabled: Bool) {
        featureFlags[name] = isEnabled
    }
    
    /// Get all feature flags
    /// - Returns: Dictionary of feature flags
    public func getAllFeatureFlags() -> [String: Bool] {
        return featureFlags
    }
    
    /// Load configuration from a plist file
    /// - Parameter url: The URL of the plist file
    /// - Returns: True if successful, false otherwise
    public func loadFromPlist(at url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            
            if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                initialize(with: plist)
                return true
            }
            
            return false
        } catch {
            Logger.error("Failed to load configuration from plist: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Load configuration from a JSON file
    /// - Parameter url: The URL of the JSON file
    /// - Returns: True if successful, false otherwise
    public func loadFromJSON(at url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                initialize(with: json)
                return true
            }
            
            return false
        } catch {
            Logger.error("Failed to load configuration from JSON: \(error.localizedDescription)")
            return false
        }
    }
}
