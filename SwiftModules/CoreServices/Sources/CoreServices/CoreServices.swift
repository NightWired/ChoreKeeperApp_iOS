import Foundation
import LocalizationHandler
import ErrorHandler

/// Main entry point for the CoreServices module
public final class CoreServices {

    // MARK: - Properties

    /// Shared instance of CoreServices
    public static let shared = CoreServices()

    /// Configuration for the module
    private var configuration: Configuration?

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern
    private init() {}

    // MARK: - Public Methods

    /// Initialize the CoreServices module with configuration
    /// - Parameter configuration: Configuration for the module
    public static func initialize(with configuration: [String: Any]) {
        // Initialize configuration
        Configuration.shared.initialize(with: configuration)

        // Initialize logger
        Logger.initialize()

        // Log initialization
        Logger.info("CoreServices module initialized")
    }

    /// Reset the CoreServices module (primarily used for testing)
    public static func reset() {
        // Reset configuration
        Configuration.shared.reset()

        // Reset dependency container
        DependencyContainer.shared.reset()

        // Reset logger
        Logger.reset()

        Logger.info("CoreServices module reset")
    }
}
