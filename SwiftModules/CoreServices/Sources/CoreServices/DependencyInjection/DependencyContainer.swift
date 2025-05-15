import Foundation

/// Dependency scope for registered services
public enum DependencyScope {
    /// A new instance is created each time the dependency is resolved
    case transient
    
    /// A single instance is created and reused for all resolutions
    case singleton
}

/// Factory for creating dependencies
public typealias DependencyFactory<T> = (DependencyContainer) -> T

/// Dependency container for service locator pattern
public final class DependencyContainer {
    
    // MARK: - Properties
    
    /// Shared instance of the dependency container
    public static let shared = DependencyContainer()
    
    /// Registered factories
    private var factories: [String: Any] = [:]
    
    /// Singleton instances
    private var singletons: [String: Any] = [:]
    
    /// Dependency scopes
    private var scopes: [String: DependencyScope] = [:]
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    // MARK: - Public Methods
    
    /// Reset the dependency container (primarily used for testing)
    public func reset() {
        factories.removeAll()
        singletons.removeAll()
        scopes.removeAll()
    }
    
    /// Register a dependency
    /// - Parameters:
    ///   - type: The type to register
    ///   - scope: The scope of the dependency
    ///   - factory: The factory to create the dependency
    public func register<T>(_ type: T.Type, scope: DependencyScope = .transient, factory: @escaping DependencyFactory<T>) {
        let key = String(describing: type)
        factories[key] = factory
        scopes[key] = scope
    }
    
    /// Register a singleton instance
    /// - Parameters:
    ///   - type: The type to register
    ///   - instance: The singleton instance
    public func registerSingleton<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        singletons[key] = instance
        scopes[key] = .singleton
    }
    
    /// Resolve a dependency
    /// - Parameter type: The type to resolve
    /// - Returns: The resolved dependency
    public func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        // Check if we have a singleton instance
        if let instance = singletons[key] as? T {
            return instance
        }
        
        // Check if we have a factory
        guard let factory = factories[key] as? DependencyFactory<T> else {
            fatalError("No factory registered for type \(key)")
        }
        
        // Get the scope
        let scope = scopes[key] ?? .transient
        
        // Create the instance
        let instance = factory(self)
        
        // Store singleton instances
        if scope == .singleton {
            singletons[key] = instance
        }
        
        return instance
    }
    
    /// Check if a dependency is registered
    /// - Parameter type: The type to check
    /// - Returns: True if registered, false otherwise
    public func isRegistered<T>(_ type: T.Type) -> Bool {
        let key = String(describing: type)
        return factories[key] != nil || singletons[key] != nil
    }
    
    /// Unregister a dependency
    /// - Parameter type: The type to unregister
    public func unregister<T>(_ type: T.Type) {
        let key = String(describing: type)
        factories.removeValue(forKey: key)
        singletons.removeValue(forKey: key)
        scopes.removeValue(forKey: key)
    }
}
