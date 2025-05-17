import Foundation
import CoreServices
import ErrorHandler
import LocalizationHandler
import DataModels

/// Main entry point for the ChoreHandler module
public final class ChoreHandler {

    // MARK: - Properties

    /// Shared instance of ChoreHandler
    public static let shared = ChoreHandler()

    /// The chore service
    public private(set) var choreService: ChoreServiceProtocol

    /// The chore generator
    public private(set) var choreGenerator: ChoreGeneratorProtocol

    /// The chore validator
    public private(set) var choreValidator: ChoreValidatorProtocol

    /// The chore scheduler
    public private(set) var choreScheduler: ChoreSchedulerProtocol

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern
    private init() {
        // Initialize services with default implementations
        self.choreService = ChoreService()
        self.choreGenerator = ChoreGenerator()
        self.choreValidator = ChoreValidator()
        self.choreScheduler = ChoreScheduler()

        // Log initialization
        Logger.info("ChoreHandler module initialized")
    }

    /// Initialize the ChoreHandler module with custom service implementations
    /// - Parameters:
    ///   - choreService: The chore service to use
    ///   - choreGenerator: The chore generator to use
    ///   - choreValidator: The chore validator to use
    ///   - choreScheduler: The chore scheduler to use
    public static func initialize(
        choreService: ChoreServiceProtocol? = nil,
        choreGenerator: ChoreGeneratorProtocol? = nil,
        choreValidator: ChoreValidatorProtocol? = nil,
        choreScheduler: ChoreSchedulerProtocol? = nil
    ) {
        // Update services if provided
        if let choreService = choreService {
            shared.choreService = choreService
        }

        if let choreGenerator = choreGenerator {
            shared.choreGenerator = choreGenerator
        }

        if let choreValidator = choreValidator {
            shared.choreValidator = choreValidator
        }

        if let choreScheduler = choreScheduler {
            shared.choreScheduler = choreScheduler
        }

        // Log initialization
        Logger.info("ChoreHandler module initialized with custom services")
    }

    /// Reset the ChoreHandler module (primarily used for testing)
    public static func reset() {
        // Reset to default implementations
        shared.choreService = ChoreService()
        shared.choreGenerator = ChoreGenerator()
        shared.choreValidator = ChoreValidator()
        shared.choreScheduler = ChoreScheduler()

        // Log reset
        Logger.info("ChoreHandler module reset")
    }

    /// Get an icon for a chore by ID
    /// - Parameter id: The ID of the icon
    /// - Returns: The ChoreIcon with the specified ID, or a default icon if not found
    public static func iconWithId(_ id: String) -> ChoreIcon {
        return ChoreIcons.find(byId: id) ?? ChoreIcons.find(byId: "custom")!
    }

    /// Get all icons for a specific category
    /// - Parameter category: The category to filter by
    /// - Returns: An array of ChoreIcon objects in the specified category
    public static func iconsForCategory(_ category: String) -> [ChoreIcon] {
        guard let category = ChoreIconCategory(rawValue: category) else {
            return []
        }
        return ChoreIcons.find(byCategory: category)
    }

    /// Get all available icons
    /// - Returns: An array of all ChoreIcon objects
    public static var allIcons: [ChoreIcon] {
        return ChoreIcons.all
    }
}
