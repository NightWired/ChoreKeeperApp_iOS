import Foundation
import CoreServices
import ErrorHandler
import CoreData

/// Main entry point for the DataModels module
public final class DataModels {

    // MARK: - Properties

    /// Shared instance of DataModels
    public static let shared = DataModels()

    /// Core Data stack
    private var coreDataStack: CoreDataStack?

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern
    private init() {}

    // MARK: - Public Methods

    /// Initialize the DataModels module with a Core Data stack
    /// - Parameter coreDataStack: The Core Data stack to use
    public static func initialize(with coreDataStack: CoreDataStack) {
        shared.coreDataStack = coreDataStack

        // Initialize repositories
        UserRepository.initialize(with: coreDataStack)
        PeriodSettingsRepository.initialize(with: coreDataStack)
        PointRepository.initialize(with: coreDataStack)
        PointTransactionRepository.initialize(with: coreDataStack)
        ChoreRepository.initialize(with: coreDataStack)

        // Log initialization
        Logger.info("DataModels module initialized")
    }

    /// Reset the DataModels module (primarily used for testing)
    public static func reset() {
        shared.coreDataStack = nil

        // Reset repositories
        UserRepository.reset()
        PeriodSettingsRepository.reset()
        PointRepository.reset()
        PointTransactionRepository.reset()
        ChoreRepository.reset()

        Logger.info("DataModels module reset")
    }

    /// Get the Core Data stack
    /// - Returns: The Core Data stack
    public func getCoreDataStack() -> CoreDataStack? {
        return coreDataStack
    }
}
