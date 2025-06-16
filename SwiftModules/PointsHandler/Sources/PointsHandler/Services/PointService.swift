import Foundation
import CoreData
import CoreServices
import ErrorHandler
import LocalizationHandler
import DataModels

/// Main service for point management operations
public class PointService {
    
    // MARK: - Properties
    
    /// Shared instance of the service
    public static let shared = PointService()
    
    /// Point repository for data operations
    private let pointRepository: PointRepository
    
    /// Point transaction repository for transaction history
    private let pointTransactionRepository: PointTransactionRepository
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    private init() {
        self.pointRepository = PointRepository.shared
        self.pointTransactionRepository = PointTransactionRepository.shared
    }
    
    // MARK: - Point Allocation Methods
    
    /// Allocate points to a user for completing a chore
    /// - Parameters:
    ///   - amount: The amount of points to allocate
    ///   - user: The user to allocate points to
    ///   - transactionType: The type of transaction
    ///   - chore: Optional chore associated with the allocation
    ///   - reward: Optional reward associated with the allocation
    ///   - penalty: Optional penalty associated with the allocation
    ///   - reason: Optional reason for the allocation
    /// - Throws: Error if the allocation fails
    public func allocatePoints(
        amount: Int16,
        to user: NSManagedObject,
        for transactionType: PointTransactionRepository.TransactionType,
        chore: NSManagedObject? = nil,
        reward: NSManagedObject? = nil,
        penalty: NSManagedObject? = nil,
        reason: String? = nil
    ) throws {
        guard amount > 0 else {
            throw AppError.pointManagement(.invalidPointAmount("Point amount must be positive for allocation"))
        }
        
        do {
            // Get configuration
            let config = PointsHandler.shared.getConfiguration()
            
            // Determine which period totals to update based on transaction type and configuration
            let updateDaily = shouldUpdatePeriodTotal(for: transactionType, period: .daily, config: config)
            let updateWeekly = shouldUpdatePeriodTotal(for: transactionType, period: .weekly, config: config)
            let updateMonthly = shouldUpdatePeriodTotal(for: transactionType, period: .monthly, config: config)
            
            // Add points to user's totals
            try pointRepository.addPoints(
                amount,
                to: user,
                updateDaily: updateDaily,
                updateWeekly: updateWeekly,
                updateMonthly: updateMonthly
            )
            
            // Get the point record for the transaction
            let pointRecord = try pointRepository.getOrCreate(for: user)
            
            // Create transaction record
            _ = try pointTransactionRepository.create(
                amount: amount,
                reason: reason ?? generateDefaultReason(for: transactionType, chore: chore, reward: reward, penalty: penalty),
                transactionType: transactionType,
                user: user,
                chore: chore,
                reward: reward,
                penalty: penalty,
                point: pointRecord
            )
            
            Logger.info("Successfully allocated \(amount) points to user \(user.value(forKey: "id") ?? "unknown")")
            
        } catch {
            Logger.error("Failed to allocate points: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointAllocationFailed(error.localizedDescription))
        }
    }
    
    /// Deduct points from a user for missing a chore or other reasons
    /// - Parameters:
    ///   - amount: The amount of points to deduct (positive value)
    ///   - user: The user to deduct points from
    ///   - transactionType: The type of transaction
    ///   - chore: Optional chore associated with the deduction
    ///   - reward: Optional reward associated with the deduction
    ///   - penalty: Optional penalty associated with the deduction
    ///   - reason: Optional reason for the deduction
    ///   - allowNegative: Whether to allow negative balance (overrides configuration)
    /// - Throws: Error if the deduction fails
    public func deductPoints(
        amount: Int16,
        from user: NSManagedObject,
        for transactionType: PointTransactionRepository.TransactionType,
        chore: NSManagedObject? = nil,
        reward: NSManagedObject? = nil,
        penalty: NSManagedObject? = nil,
        reason: String? = nil,
        allowNegative: Bool? = nil
    ) throws {
        guard amount > 0 else {
            throw AppError.pointManagement(.invalidPointAmount("Point amount must be positive for deduction"))
        }
        
        do {
            // Get configuration
            let config = PointsHandler.shared.getConfiguration()
            let allowNegativeBalance = allowNegative ?? config.allowNegativeBalances
            
            // Determine which period totals to update based on transaction type and configuration
            let updateDaily = shouldUpdatePeriodTotal(for: transactionType, period: .daily, config: config)
            let updateWeekly = shouldUpdatePeriodTotal(for: transactionType, period: .weekly, config: config)
            let updateMonthly = shouldUpdatePeriodTotal(for: transactionType, period: .monthly, config: config)
            
            // Subtract points from user's totals
            try pointRepository.subtractPoints(
                amount,
                from: user,
                allowNegative: allowNegativeBalance,
                updateDaily: updateDaily,
                updateWeekly: updateWeekly,
                updateMonthly: updateMonthly
            )
            
            // Get the point record for the transaction
            let pointRecord = try pointRepository.getOrCreate(for: user)
            
            // Create transaction record (negative amount for deduction)
            _ = try pointTransactionRepository.create(
                amount: -amount,
                reason: reason ?? generateDefaultReason(for: transactionType, chore: chore, reward: reward, penalty: penalty),
                transactionType: transactionType,
                user: user,
                chore: chore,
                reward: reward,
                penalty: penalty,
                point: pointRecord
            )
            
            Logger.info("Successfully deducted \(amount) points from user \(user.value(forKey: "id") ?? "unknown")")
            
        } catch {
            Logger.error("Failed to deduct points: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointDeductionFailed(error.localizedDescription))
        }
    }
    
    /// Manually adjust points for a user (can be positive or negative)
    /// - Parameters:
    ///   - amount: The amount to adjust (positive for addition, negative for subtraction)
    ///   - user: The user to adjust points for
    ///   - reason: The reason for the adjustment
    ///   - adjustedBy: The user making the adjustment (typically a parent)
    ///   - allowNegative: Whether to allow negative balance (overrides configuration)
    /// - Throws: Error if the adjustment fails
    public func adjustPoints(
        amount: Int16,
        for user: NSManagedObject,
        reason: String,
        adjustedBy: NSManagedObject? = nil,
        allowNegative: Bool? = nil
    ) throws {
        guard amount != 0 else {
            throw AppError.pointManagement(.invalidPointAmount("Point adjustment amount cannot be zero"))
        }
        
        do {
            let config = PointsHandler.shared.getConfiguration()
            let allowNegativeBalance = allowNegative ?? config.allowNegativeBalances
            
            // Determine which period totals to update
            let updateDaily = config.trackAdjustmentsInPeriods
            let updateWeekly = config.trackAdjustmentsInPeriods
            let updateMonthly = config.trackAdjustmentsInPeriods
            
            if amount > 0 {
                // Add points
                try pointRepository.addPoints(
                    amount,
                    to: user,
                    updateDaily: updateDaily,
                    updateWeekly: updateWeekly,
                    updateMonthly: updateMonthly
                )
            } else {
                // Subtract points
                try pointRepository.subtractPoints(
                    abs(amount),
                    from: user,
                    allowNegative: allowNegativeBalance,
                    updateDaily: updateDaily,
                    updateWeekly: updateWeekly,
                    updateMonthly: updateMonthly
                )
            }
            
            // Get the point record for the transaction
            let pointRecord = try pointRepository.getOrCreate(for: user)
            
            // Create transaction record
            let adjustmentReason: String
            if let adjustedBy = adjustedBy {
                let parentName = adjustedBy.value(forKey: "firstName") as? String ?? "Parent"
                if amount > 0 {
                    adjustmentReason = LocalizationHandler.localize("points.transactions.manual_addition", with: ["parent": parentName])
                } else {
                    adjustmentReason = LocalizationHandler.localize("points.transactions.manual_deduction", with: ["parent": parentName])
                }
            } else {
                adjustmentReason = reason
            }
            
            _ = try pointTransactionRepository.create(
                amount: amount,
                reason: "\(adjustmentReason): \(reason)",
                transactionType: .manualAdjustment,
                user: user,
                point: pointRecord
            )
            
            Logger.info("Successfully adjusted \(amount) points for user \(user.value(forKey: "id") ?? "unknown")")
            
        } catch {
            Logger.error("Failed to adjust points: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointAdjustmentFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Point Query Methods
    
    /// Get current point totals for a user
    /// - Parameter user: The user to get totals for
    /// - Returns: PointTotals structure with current, daily, weekly, and monthly totals
    /// - Throws: Error if the query fails
    public func getPointTotals(for user: NSManagedObject) throws -> PointTotals {
        do {
            let totals = try pointRepository.getTotals(for: user)
            return PointTotals(
                current: totals["current"] ?? 0,
                daily: totals["daily"] ?? 0,
                weekly: totals["weekly"] ?? 0,
                monthly: totals["monthly"] ?? 0
            )
        } catch {
            Logger.error("Failed to get point totals: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointCalculationError(error.localizedDescription))
        }
    }
    
    /// Check if a user has sufficient points for a transaction
    /// - Parameters:
    ///   - user: The user to check
    ///   - amount: The amount to check for
    /// - Returns: True if the user has sufficient points
    /// - Throws: Error if the check fails
    public func hasSufficientPoints(_ user: NSManagedObject, amount: Int16) throws -> Bool {
        do {
            return try pointRepository.hasSufficientPoints(user, amount: amount)
        } catch {
            Logger.error("Failed to check sufficient points: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointCalculationError(error.localizedDescription))
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Determine if period totals should be updated for a transaction type
    private func shouldUpdatePeriodTotal(
        for transactionType: PointTransactionRepository.TransactionType,
        period: PointPeriod,
        config: PointsConfiguration
    ) -> Bool {
        switch transactionType {
        case .choreCompletion:
            return config.trackCompletionInPeriods
        case .choreMissed:
            return config.trackMissedInPeriods
        case .manualAdjustment, .bonus, .correction:
            return config.trackAdjustmentsInPeriods
        case .rewardRedemption, .penaltyApplied:
            return false // These typically don't count toward earning totals
        }
    }
    
    /// Generate a default reason for a transaction
    private func generateDefaultReason(
        for transactionType: PointTransactionRepository.TransactionType,
        chore: NSManagedObject? = nil,
        reward: NSManagedObject? = nil,
        penalty: NSManagedObject? = nil
    ) -> String {
        switch transactionType {
        case .choreCompletion:
            if let chore = chore, let choreName = chore.value(forKey: "title") as? String {
                return LocalizationHandler.localize("points.transactions.earned_from_chore", with: ["chore": choreName])
            }
            return LocalizationHandler.localize("points.transactions.types.chore_completion")

        case .choreMissed:
            if let chore = chore, let choreName = chore.value(forKey: "title") as? String {
                return LocalizationHandler.localize("points.transactions.lost_from_missed_chore", with: ["chore": choreName])
            }
            return LocalizationHandler.localize("points.transactions.types.chore_missed")

        case .rewardRedemption:
            if let reward = reward, let rewardName = reward.value(forKey: "title") as? String {
                return LocalizationHandler.localize("points.transactions.spent_on_reward", with: ["reward": rewardName])
            }
            return LocalizationHandler.localize("points.transactions.types.reward_redemption")

        case .penaltyApplied:
            if let penalty = penalty, let penaltyName = penalty.value(forKey: "title") as? String {
                return LocalizationHandler.localize("points.transactions.penalty_deduction", with: ["penalty": penaltyName])
            }
            return LocalizationHandler.localize("points.transactions.types.penalty_applied")
            
        case .manualAdjustment:
            return LocalizationHandler.localize("points.transactions.types.manual_adjustment")
            
        case .bonus:
            return LocalizationHandler.localize("points.transactions.bonus_points")
            
        case .correction:
            return LocalizationHandler.localize("points.transactions.correction_adjustment")
        }
    }

    // MARK: - Transaction History Methods

    /// Get transaction history for a user
    /// - Parameters:
    ///   - user: The user to get history for
    ///   - limit: Maximum number of transactions to return
    ///   - offset: Number of transactions to skip
    ///   - transactionType: Optional filter by transaction type
    ///   - startDate: Optional start date filter
    ///   - endDate: Optional end date filter
    /// - Returns: Array of transaction records
    /// - Throws: Error if the query fails
    public func getTransactionHistory(
        for user: NSManagedObject,
        limit: Int? = nil,
        offset: Int = 0,
        transactionType: PointTransactionRepository.TransactionType? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) throws -> [NSManagedObject] {
        do {
            if let startDate = startDate, let endDate = endDate {
                return try pointTransactionRepository.fetchByDateRange(
                    startDate: startDate,
                    endDate: endDate,
                    user: user,
                    transactionType: transactionType
                )
            } else if let transactionType = transactionType {
                return try pointTransactionRepository.fetchByType(
                    transactionType,
                    user: user,
                    limit: limit
                )
            } else {
                return try pointTransactionRepository.fetchByUser(
                    user,
                    limit: limit,
                    offset: offset
                )
            }
        } catch {
            Logger.error("Failed to get transaction history: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointHistoryError(error.localizedDescription))
        }
    }

    /// Get point statistics for a user
    /// - Parameters:
    ///   - user: The user to get statistics for
    ///   - startDate: Optional start date for the period
    ///   - endDate: Optional end date for the period
    /// - Returns: PointStatistics structure
    /// - Throws: Error if the calculation fails
    public func getStatistics(
        for user: NSManagedObject,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) throws -> PointStatistics {
        do {
            let stats = try pointTransactionRepository.getStatistics(
                for: user,
                startDate: startDate,
                endDate: endDate
            )

            let totalEarned = stats["totalEarned"] as? Int16 ?? 0
            let totalSpent = stats["totalSpent"] as? Int16 ?? 0
            let netPoints = stats["netPoints"] as? Int16 ?? 0
            let transactionCount = stats["transactionCount"] as? Int ?? 0
            let typeBreakdown = stats["typeBreakdown"] as? [String: Int] ?? [:]

            // Calculate averages (simplified - would need more sophisticated calculation for real averages)
            let averageDaily = transactionCount > 0 ? Double(totalEarned) / max(1.0, Double(transactionCount)) : 0.0
            let averageWeekly = averageDaily * 7.0
            let averageMonthly = averageDaily * 30.0

            return PointStatistics(
                totalEarned: totalEarned,
                totalSpent: totalSpent,
                netPoints: netPoints,
                transactionCount: transactionCount,
                averageDaily: averageDaily,
                averageWeekly: averageWeekly,
                averageMonthly: averageMonthly,
                typeBreakdown: typeBreakdown
            )
        } catch {
            Logger.error("Failed to get point statistics: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointStatisticsError(error.localizedDescription))
        }
    }

    // MARK: - Period Management Methods

    /// Reset daily totals for a user
    /// - Parameter user: The user to reset totals for
    /// - Throws: Error if the reset fails
    public func resetDailyTotals(for user: NSManagedObject) throws {
        do {
            try pointRepository.resetPeriodTotals(for: user, resetDaily: true)
            Logger.info("Reset daily totals for user \(user.value(forKey: "id") ?? "unknown")")
        } catch {
            Logger.error("Failed to reset daily totals: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointCalculationError(error.localizedDescription))
        }
    }

    /// Reset weekly totals for a user
    /// - Parameter user: The user to reset totals for
    /// - Throws: Error if the reset fails
    public func resetWeeklyTotals(for user: NSManagedObject) throws {
        do {
            try pointRepository.resetPeriodTotals(for: user, resetWeekly: true)
            Logger.info("Reset weekly totals for user \(user.value(forKey: "id") ?? "unknown")")
        } catch {
            Logger.error("Failed to reset weekly totals: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointCalculationError(error.localizedDescription))
        }
    }

    /// Reset monthly totals for a user
    /// - Parameter user: The user to reset totals for
    /// - Throws: Error if the reset fails
    public func resetMonthlyTotals(for user: NSManagedObject) throws {
        do {
            try pointRepository.resetPeriodTotals(for: user, resetMonthly: true)
            Logger.info("Reset monthly totals for user \(user.value(forKey: "id") ?? "unknown")")
        } catch {
            Logger.error("Failed to reset monthly totals: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointCalculationError(error.localizedDescription))
        }
    }

    /// Reset all period totals for a user
    /// - Parameter user: The user to reset totals for
    /// - Throws: Error if the reset fails
    public func resetAllPeriodTotals(for user: NSManagedObject) throws {
        do {
            try pointRepository.resetPeriodTotals(
                for: user,
                resetDaily: true,
                resetWeekly: true,
                resetMonthly: true
            )
            Logger.info("Reset all period totals for user \(user.value(forKey: "id") ?? "unknown")")
        } catch {
            Logger.error("Failed to reset all period totals: \(error.localizedDescription)")
            throw AppError.pointManagement(.pointCalculationError(error.localizedDescription))
        }
    }
}
