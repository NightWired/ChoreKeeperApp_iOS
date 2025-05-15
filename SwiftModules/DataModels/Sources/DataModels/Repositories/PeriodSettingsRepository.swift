import Foundation
import CoreData
import CoreServices
import ErrorHandler

/// Repository for PeriodSettings entities
public class PeriodSettingsRepository: AbstractRepository<NSManagedObject> {

    // MARK: - Properties

    /// Shared instance of the repository
    public static let shared = PeriodSettingsRepository()

    /// The entity name
    public override class var entityName: String {
        return "PeriodSettings"
    }

    // MARK: - Public Methods

    /// Create new period settings
    /// - Parameters:
    ///   - period: The period (daily, weekly, monthly)
    ///   - type: The type (reward, penalty)
    ///   - applicationMode: The application mode (cumulative, highestTier)
    ///   - family: The family the settings belong to
    /// - Returns: The created period settings
    /// - Throws: Error if the creation fails
    public func create(period: String, type: String, applicationMode: String, family: NSManagedObject) throws -> NSManagedObject {
        let attributes: [String: Any] = [
            "id": Int64(Date().timeIntervalSince1970 * 1000),
            "period": period,
            "type": type,
            "applicationMode": applicationMode,
            "createdAt": Date(),
            "updatedAt": Date()
        ]

        let periodSettings = try create(with: attributes)

        // Set the family relationship
        periodSettings.setValue(family, forKey: "family")

        var saveError: Error?

        performOnMainContext { context in
            do {
                try context.save()
            } catch {
                saveError = error
            }
        } completion: { error in
            if let error = error {
                saveError = error
            }
        }

        if let saveError = saveError {
            Logger.error("Failed to associate period settings with family: \(saveError.localizedDescription)")
            throw DataModelError.updateFailed(saveError.localizedDescription)
        }

        return periodSettings
    }

    /// Update period settings
    /// - Parameters:
    ///   - periodSettings: The period settings to update
    ///   - applicationMode: The new application mode
    /// - Throws: Error if the update fails
    public func updateApplicationMode(periodSettings: NSManagedObject, applicationMode: String) throws {
        let attributes: [String: Any] = [
            "applicationMode": applicationMode,
            "updatedAt": Date()
        ]

        try update(periodSettings, with: attributes)
    }

    /// Fetch period settings by period and type
    /// - Parameters:
    ///   - period: The period to fetch
    ///   - type: The type to fetch
    ///   - family: The family to fetch for
    /// - Returns: The period settings, or nil if not found
    /// - Throws: Error if the fetch fails
    public func fetchByPeriodAndType(period: String, type: String, family: NSManagedObject) throws -> NSManagedObject? {
        guard let familyId = family.value(forKey: "id") else {
            throw DataModelError.invalidData("Family ID is nil")
        }

        let predicate = NSPredicate(format: "period == %@ AND type == %@ AND family.id == %@", period, type, familyId as! CVarArg)
        let periodSettings = try fetch(with: predicate)
        return periodSettings.first
    }

    /// Get or create period settings
    /// - Parameters:
    ///   - period: The period
    ///   - type: The type
    ///   - family: The family
    ///   - defaultApplicationMode: The default application mode if settings don't exist
    /// - Returns: The period settings
    /// - Throws: Error if the fetch or creation fails
    public func getOrCreate(period: String, type: String, family: NSManagedObject, defaultApplicationMode: String) throws -> NSManagedObject {
        if let existingSettings = try fetchByPeriodAndType(period: period, type: type, family: family) {
            return existingSettings
        }

        return try create(period: period, type: type, applicationMode: defaultApplicationMode, family: family)
    }

    /// Initialize default period settings for a family
    /// - Parameter family: The family to initialize settings for
    /// - Throws: Error if the initialization fails
    public func initializeDefaultSettings(for family: NSManagedObject) throws {
        // Create default settings for each period and type combination
        let periods = ["daily", "weekly", "monthly"]
        let types = ["reward", "penalty"]

        for period in periods {
            for type in types {
                // Default to cumulative for rewards, highest tier for penalties
                let defaultMode = type == "reward" ? "cumulative" : "highestTier"

                _ = try getOrCreate(period: period, type: type, family: family, defaultApplicationMode: defaultMode)
            }
        }
    }

    /// Get the application mode for a period and type
    /// - Parameters:
    ///   - period: The period
    ///   - type: The type
    ///   - family: The family
    /// - Returns: The application mode
    /// - Throws: Error if the fetch fails
    public func getApplicationMode(period: String, type: String, family: NSManagedObject) throws -> String {
        let settings = try getOrCreate(
            period: period,
            type: type,
            family: family,
            defaultApplicationMode: type == "reward" ? "cumulative" : "highestTier"
        )

        return settings.value(forKey: "applicationMode") as? String ?? "cumulative"
    }
}
