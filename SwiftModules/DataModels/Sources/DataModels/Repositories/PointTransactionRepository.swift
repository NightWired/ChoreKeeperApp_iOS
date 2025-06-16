import Foundation
import CoreData
import CoreServices
import ErrorHandler

/// Repository for PointTransaction entities
public class PointTransactionRepository: AbstractRepository<NSManagedObject> {

    // MARK: - Properties

    /// Shared instance of the repository
    public static let shared = PointTransactionRepository()

    /// The entity name
    public override class var entityName: String {
        return "PointTransaction"
    }

    // MARK: - Transaction Types

    public enum TransactionType: String, CaseIterable {
        case choreCompletion = "chore_completion"
        case choreMissed = "chore_missed"
        case manualAdjustment = "manual_adjustment"
        case rewardRedemption = "reward_redemption"
        case penaltyApplied = "penalty_applied"
        case bonus = "bonus"
        case correction = "correction"
    }

    // MARK: - Public Methods

    /// Create a new point transaction
    /// - Parameters:
    ///   - amount: The amount of points (positive for additions, negative for subtractions)
    ///   - reason: The reason for the transaction
    ///   - transactionType: The type of transaction
    ///   - user: The user the transaction applies to
    ///   - chore: Optional chore associated with the transaction
    ///   - reward: Optional reward associated with the transaction
    ///   - penalty: Optional penalty associated with the transaction
    ///   - point: Optional point record associated with the transaction
    /// - Returns: The created transaction
    /// - Throws: Error if the creation fails
    public func create(
        amount: Int16,
        reason: String?,
        transactionType: TransactionType,
        user: NSManagedObject,
        chore: NSManagedObject? = nil,
        reward: NSManagedObject? = nil,
        penalty: NSManagedObject? = nil,
        point: NSManagedObject? = nil
    ) throws -> NSManagedObject {
        let attributes: [String: Any] = [
            "id": Int64(Date().timeIntervalSince1970 * 1000),
            "amount": amount,
            "reason": reason ?? "",
            "transactionType": transactionType.rawValue,
            "createdAt": Date()
        ]

        let transaction = try create(with: attributes)

        // Set relationships
        transaction.setValue(user, forKey: "user")
        
        if let chore = chore {
            transaction.setValue(chore, forKey: "chore")
        }
        
        if let reward = reward {
            transaction.setValue(reward, forKey: "reward")
        }
        
        if let penalty = penalty {
            transaction.setValue(penalty, forKey: "penalty")
        }
        
        if let point = point {
            transaction.setValue(point, forKey: "point")
        }

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
            Logger.error("Failed to save point transaction: \(saveError.localizedDescription)")
            throw DataModelError.createFailed(saveError.localizedDescription)
        }

        return transaction
    }

    /// Fetch transactions for a specific user
    /// - Parameters:
    ///   - user: The user to fetch transactions for
    ///   - limit: Maximum number of transactions to fetch (optional)
    ///   - offset: Number of transactions to skip (optional)
    ///   - sortDescending: Whether to sort by creation date descending (default: true)
    /// - Returns: Array of transactions
    /// - Throws: Error if the fetch fails
    public func fetchByUser(
        _ user: NSManagedObject,
        limit: Int? = nil,
        offset: Int = 0,
        sortDescending: Bool = true
    ) throws -> [NSManagedObject] {
        let userId = user.value(forKey: "id") as? Int64 ?? 0

        var query = QueryBuilder<NSManagedObject>()
            .filter(key: "user.id", value: userId)
            .sort(key: "createdAt", direction: sortDescending ? .descending : .ascending)
            .offset(offset)

        if let limit = limit {
            query = query.limit(limit)
        }

        return try fetch(with: query)
    }

    /// Fetch transactions by type
    /// - Parameters:
    ///   - transactionType: The type of transaction to fetch
    ///   - user: Optional user to filter by
    ///   - limit: Maximum number of transactions to fetch (optional)
    ///   - sortDescending: Whether to sort by creation date descending (default: true)
    /// - Returns: Array of transactions
    /// - Throws: Error if the fetch fails
    public func fetchByType(
        _ transactionType: TransactionType,
        user: NSManagedObject? = nil,
        limit: Int? = nil,
        sortDescending: Bool = true
    ) throws -> [NSManagedObject] {
        var query = QueryBuilder<NSManagedObject>()
            .filter(key: "transactionType", value: transactionType.rawValue)
            .sort(key: "createdAt", direction: sortDescending ? .descending : .ascending)

        if let user = user {
            let userId = user.value(forKey: "id") as? Int64 ?? 0
            query = query.filter(key: "user.id", value: userId)
        }

        if let limit = limit {
            query = query.limit(limit)
        }

        return try fetch(with: query)
    }

    /// Fetch transactions within a date range
    /// - Parameters:
    ///   - startDate: Start date for the range
    ///   - endDate: End date for the range
    ///   - user: Optional user to filter by
    ///   - transactionType: Optional transaction type to filter by
    ///   - sortDescending: Whether to sort by creation date descending (default: true)
    /// - Returns: Array of transactions
    /// - Throws: Error if the fetch fails
    public func fetchByDateRange(
        startDate: Date,
        endDate: Date,
        user: NSManagedObject? = nil,
        transactionType: TransactionType? = nil,
        sortDescending: Bool = true
    ) throws -> [NSManagedObject] {
        var query = QueryBuilder<NSManagedObject>()
            .filter(key: "createdAt", value: startDate, operator: .greaterThanOrEqual)
            .filter(key: "createdAt", value: endDate, operator: .lessThanOrEqual)
            .sort(key: "createdAt", direction: sortDescending ? .descending : .ascending)

        if let user = user {
            let userId = user.value(forKey: "id") as? Int64 ?? 0
            query = query.filter(key: "user.id", value: userId)
        }

        if let transactionType = transactionType {
            query = query.filter(key: "transactionType", value: transactionType.rawValue)
        }

        return try fetch(with: query)
    }

    /// Get transaction statistics for a user
    /// - Parameters:
    ///   - user: The user to get statistics for
    ///   - startDate: Optional start date for the period
    ///   - endDate: Optional end date for the period
    /// - Returns: Dictionary with statistics
    /// - Throws: Error if the fetch fails
    public func getStatistics(
        for user: NSManagedObject,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) throws -> [String: Any] {
        var predicateFormat = "user.id == %lld"
        var arguments: [Any] = [user.value(forKey: "id") as? Int64 ?? 0]
        
        if let startDate = startDate {
            predicateFormat += " AND createdAt >= %@"
            arguments.append(startDate)
        }
        
        if let endDate = endDate {
            predicateFormat += " AND createdAt <= %@"
            arguments.append(endDate)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: arguments)
        let transactions = try fetch(with: predicate)
        
        var totalEarned: Int16 = 0
        var totalSpent: Int16 = 0
        var transactionCount = 0
        var typeBreakdown: [String: Int] = [:]
        
        for transaction in transactions {
            let amount = transaction.value(forKey: "amount") as? Int16 ?? 0
            let type = transaction.value(forKey: "transactionType") as? String ?? ""
            
            if amount > 0 {
                totalEarned += amount
            } else {
                totalSpent += abs(amount)
            }
            
            transactionCount += 1
            typeBreakdown[type] = (typeBreakdown[type] ?? 0) + 1
        }
        
        return [
            "totalEarned": totalEarned,
            "totalSpent": totalSpent,
            "netPoints": totalEarned - totalSpent,
            "transactionCount": transactionCount,
            "typeBreakdown": typeBreakdown
        ]
    }

    /// Delete transactions older than a specified date
    /// - Parameters:
    ///   - cutoffDate: Date before which transactions should be deleted
    ///   - user: Optional user to filter by
    /// - Returns: Number of transactions deleted
    /// - Throws: Error if the deletion fails
    public func deleteOlderThan(
        _ cutoffDate: Date,
        user: NSManagedObject? = nil
    ) throws -> Int {
        var predicateFormat = "createdAt < %@"
        var arguments: [Any] = [cutoffDate]
        
        if let user = user {
            let userId = user.value(forKey: "id") as? Int64 ?? 0
            predicateFormat += " AND user.id == %lld"
            arguments.append(userId)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: arguments)
        let transactionsToDelete = try fetch(with: predicate)
        
        for transaction in transactionsToDelete {
            try delete(transaction)
        }
        
        return transactionsToDelete.count
    }

    /// Get the most recent transaction for a user
    /// - Parameter user: The user to get the most recent transaction for
    /// - Returns: The most recent transaction or nil if none found
    /// - Throws: Error if the fetch fails
    public func getMostRecent(for user: NSManagedObject) throws -> NSManagedObject? {
        let transactions = try fetchByUser(user, limit: 1, sortDescending: true)
        return transactions.first
    }

    /// Get total points earned/spent by transaction type
    /// - Parameters:
    ///   - user: The user to get totals for
    ///   - transactionType: The transaction type to filter by
    ///   - startDate: Optional start date
    ///   - endDate: Optional end date
    /// - Returns: Total amount for the specified type
    /// - Throws: Error if the fetch fails
    public func getTotalByType(
        for user: NSManagedObject,
        transactionType: TransactionType,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) throws -> Int16 {
        let transactions = try fetchByDateRange(
            startDate: startDate ?? Date.distantPast,
            endDate: endDate ?? Date(),
            user: user,
            transactionType: transactionType
        )
        
        return transactions.reduce(0) { total, transaction in
            total + (transaction.value(forKey: "amount") as? Int16 ?? 0)
        }
    }
}
