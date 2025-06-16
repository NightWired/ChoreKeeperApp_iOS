import Foundation
import CoreData
import CoreServices
import ErrorHandler

/// Repository for Point entities
public class PointRepository: AbstractRepository<NSManagedObject> {

    // MARK: - Properties

    /// Shared instance of the repository
    public static let shared = PointRepository()

    /// The entity name
    public override class var entityName: String {
        return "Point"
    }

    // MARK: - Public Methods

    /// Create new point record for a user
    /// - Parameters:
    ///   - user: The user to create points for
    ///   - currentTotal: Initial current total (default: 0)
    ///   - dailyTotal: Initial daily total (default: 0)
    ///   - weeklyTotal: Initial weekly total (default: 0)
    ///   - monthlyTotal: Initial monthly total (default: 0)
    /// - Returns: The created point record
    /// - Throws: Error if the creation fails
    public func create(
        for user: NSManagedObject,
        currentTotal: Int16 = 0,
        dailyTotal: Int16 = 0,
        weeklyTotal: Int16 = 0,
        monthlyTotal: Int16 = 0
    ) throws -> NSManagedObject {
        let attributes: [String: Any] = [
            "id": Int64(Date().timeIntervalSince1970 * 1000),
            "currentTotal": currentTotal,
            "dailyTotal": dailyTotal,
            "weeklyTotal": weeklyTotal,
            "monthlyTotal": monthlyTotal,
            "updatedAt": Date()
        ]

        let point = try create(with: attributes)

        // Set the user relationship
        point.setValue(user, forKey: "user")

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
            Logger.error("Failed to associate point with user: \(saveError.localizedDescription)")
            throw DataModelError.updateFailed(saveError.localizedDescription)
        }

        return point
    }

    /// Fetch point record for a specific user
    /// - Parameter user: The user to fetch points for
    /// - Returns: The point record or nil if not found
    /// - Throws: Error if the fetch fails
    public func fetchByUser(_ user: NSManagedObject) throws -> NSManagedObject? {
        let userId = user.value(forKey: "id") as? Int64 ?? 0
        
        let predicate = NSPredicate(format: "user.id == %lld AND deletedAt == nil", userId)
        let results = try fetch(with: predicate)
        
        return results.first
    }

    /// Get or create point record for a user
    /// - Parameter user: The user to get or create points for
    /// - Returns: The point record
    /// - Throws: Error if the operation fails
    public func getOrCreate(for user: NSManagedObject) throws -> NSManagedObject {
        if let existingPoints = try fetchByUser(user) {
            return existingPoints
        }
        
        return try create(for: user)
    }

    /// Update point totals for a user
    /// - Parameters:
    ///   - user: The user to update points for
    ///   - currentTotal: New current total (optional)
    ///   - dailyTotal: New daily total (optional)
    ///   - weeklyTotal: New weekly total (optional)
    ///   - monthlyTotal: New monthly total (optional)
    /// - Throws: Error if the update fails
    public func updateTotals(
        for user: NSManagedObject,
        currentTotal: Int16? = nil,
        dailyTotal: Int16? = nil,
        weeklyTotal: Int16? = nil,
        monthlyTotal: Int16? = nil
    ) throws {
        let pointRecord = try getOrCreate(for: user)
        
        var attributes: [String: Any] = [
            "updatedAt": Date()
        ]
        
        if let currentTotal = currentTotal {
            attributes["currentTotal"] = currentTotal
        }
        if let dailyTotal = dailyTotal {
            attributes["dailyTotal"] = dailyTotal
        }
        if let weeklyTotal = weeklyTotal {
            attributes["weeklyTotal"] = weeklyTotal
        }
        if let monthlyTotal = monthlyTotal {
            attributes["monthlyTotal"] = monthlyTotal
        }
        
        try update(pointRecord, with: attributes)
    }

    /// Add points to a user's totals
    /// - Parameters:
    ///   - amount: Amount to add
    ///   - user: The user to add points to
    ///   - updateDaily: Whether to update daily total (default: true)
    ///   - updateWeekly: Whether to update weekly total (default: true)
    ///   - updateMonthly: Whether to update monthly total (default: true)
    /// - Throws: Error if the operation fails
    public func addPoints(
        _ amount: Int16,
        to user: NSManagedObject,
        updateDaily: Bool = true,
        updateWeekly: Bool = true,
        updateMonthly: Bool = true
    ) throws {
        let pointRecord = try getOrCreate(for: user)
        
        let currentTotal = (pointRecord.value(forKey: "currentTotal") as? Int16 ?? 0) + amount
        let dailyTotal = updateDaily ? (pointRecord.value(forKey: "dailyTotal") as? Int16 ?? 0) + amount : pointRecord.value(forKey: "dailyTotal") as? Int16 ?? 0
        let weeklyTotal = updateWeekly ? (pointRecord.value(forKey: "weeklyTotal") as? Int16 ?? 0) + amount : pointRecord.value(forKey: "weeklyTotal") as? Int16 ?? 0
        let monthlyTotal = updateMonthly ? (pointRecord.value(forKey: "monthlyTotal") as? Int16 ?? 0) + amount : pointRecord.value(forKey: "monthlyTotal") as? Int16 ?? 0
        
        try updateTotals(
            for: user,
            currentTotal: currentTotal,
            dailyTotal: dailyTotal,
            weeklyTotal: weeklyTotal,
            monthlyTotal: monthlyTotal
        )
    }

    /// Subtract points from a user's totals
    /// - Parameters:
    ///   - amount: Amount to subtract
    ///   - user: The user to subtract points from
    ///   - allowNegative: Whether to allow negative balances (default: false)
    ///   - updateDaily: Whether to update daily total (default: false for subtractions)
    ///   - updateWeekly: Whether to update weekly total (default: false for subtractions)
    ///   - updateMonthly: Whether to update monthly total (default: false for subtractions)
    /// - Throws: Error if the operation fails or would result in negative balance when not allowed
    public func subtractPoints(
        _ amount: Int16,
        from user: NSManagedObject,
        allowNegative: Bool = false,
        updateDaily: Bool = false,
        updateWeekly: Bool = false,
        updateMonthly: Bool = false
    ) throws {
        let pointRecord = try getOrCreate(for: user)
        
        let currentTotal = (pointRecord.value(forKey: "currentTotal") as? Int16 ?? 0) - amount
        
        if !allowNegative && currentTotal < 0 {
            throw AppError.pointManagement(.insufficientPoints("User does not have enough points"))
        }
        
        let dailyTotal = updateDaily ? (pointRecord.value(forKey: "dailyTotal") as? Int16 ?? 0) - amount : pointRecord.value(forKey: "dailyTotal") as? Int16 ?? 0
        let weeklyTotal = updateWeekly ? (pointRecord.value(forKey: "weeklyTotal") as? Int16 ?? 0) - amount : pointRecord.value(forKey: "weeklyTotal") as? Int16 ?? 0
        let monthlyTotal = updateMonthly ? (pointRecord.value(forKey: "monthlyTotal") as? Int16 ?? 0) - amount : pointRecord.value(forKey: "monthlyTotal") as? Int16 ?? 0
        
        try updateTotals(
            for: user,
            currentTotal: currentTotal,
            dailyTotal: dailyTotal,
            weeklyTotal: weeklyTotal,
            monthlyTotal: monthlyTotal
        )
    }

    /// Reset period totals (daily, weekly, or monthly)
    /// - Parameters:
    ///   - user: The user to reset totals for
    ///   - resetDaily: Whether to reset daily total
    ///   - resetWeekly: Whether to reset weekly total
    ///   - resetMonthly: Whether to reset monthly total
    /// - Throws: Error if the operation fails
    public func resetPeriodTotals(
        for user: NSManagedObject,
        resetDaily: Bool = false,
        resetWeekly: Bool = false,
        resetMonthly: Bool = false
    ) throws {
        let pointRecord = try getOrCreate(for: user)
        
        var attributes: [String: Any] = [
            "updatedAt": Date()
        ]
        
        if resetDaily {
            attributes["dailyTotal"] = Int16(0)
        }
        if resetWeekly {
            attributes["weeklyTotal"] = Int16(0)
        }
        if resetMonthly {
            attributes["monthlyTotal"] = Int16(0)
        }
        
        if !attributes.isEmpty {
            try update(pointRecord, with: attributes)
        }
    }

    /// Get current point totals for a user
    /// - Parameter user: The user to get totals for
    /// - Returns: Dictionary with current, daily, weekly, and monthly totals
    /// - Throws: Error if the fetch fails
    public func getTotals(for user: NSManagedObject) throws -> [String: Int16] {
        let pointRecord = try getOrCreate(for: user)
        
        return [
            "current": pointRecord.value(forKey: "currentTotal") as? Int16 ?? 0,
            "daily": pointRecord.value(forKey: "dailyTotal") as? Int16 ?? 0,
            "weekly": pointRecord.value(forKey: "weeklyTotal") as? Int16 ?? 0,
            "monthly": pointRecord.value(forKey: "monthlyTotal") as? Int16 ?? 0
        ]
    }

    /// Check if user has sufficient points
    /// - Parameters:
    ///   - user: The user to check
    ///   - amount: The amount to check for
    /// - Returns: True if user has sufficient points
    /// - Throws: Error if the fetch fails
    public func hasSufficientPoints(_ user: NSManagedObject, amount: Int16) throws -> Bool {
        let totals = try getTotals(for: user)
        return (totals["current"] ?? 0) >= amount
    }
}
