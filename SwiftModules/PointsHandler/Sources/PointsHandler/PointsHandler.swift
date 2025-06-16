import Foundation
import CoreServices
import ErrorHandler
import LocalizationHandler
import DataModels

/// Main entry point for the PointsHandler module
public final class PointsHandler {

    // MARK: - Properties

    /// Shared instance of PointsHandler
    public static let shared = PointsHandler()

    /// Configuration for the points system
    private var configuration: PointsConfiguration

    /// Whether the module has been initialized
    private var isInitialized = false

    // MARK: - Initialization

    /// Private initializer to enforce singleton pattern
    private init() {
        self.configuration = PointsConfiguration()
    }

    // MARK: - Public Methods

    /// Initialize the PointsHandler module
    /// - Parameter configuration: Optional configuration for the points system
    public static func initialize(with configuration: PointsConfiguration? = nil) {
        if let config = configuration {
            shared.configuration = config
        }
        
        shared.isInitialized = true
        
        // Log initialization
        Logger.info("PointsHandler module initialized")
    }

    /// Reset the PointsHandler module (primarily used for testing)
    public static func reset() {
        shared.configuration = PointsConfiguration()
        shared.isInitialized = false
        
        Logger.info("PointsHandler module reset")
    }

    /// Get the current configuration
    /// - Returns: The current points configuration
    public func getConfiguration() -> PointsConfiguration {
        return configuration
    }

    /// Update the configuration
    /// - Parameter configuration: The new configuration
    public func updateConfiguration(_ configuration: PointsConfiguration) {
        self.configuration = configuration
        Logger.info("PointsHandler configuration updated")
    }

    /// Check if the module is initialized
    /// - Returns: True if initialized, false otherwise
    public func isModuleInitialized() -> Bool {
        return isInitialized
    }
}

/// Configuration for the points system
public struct PointsConfiguration {
    
    // MARK: - Properties
    
    /// Whether to allow negative point balances
    public var allowNegativeBalances: Bool
    
    /// Maximum number of transactions to keep in history per user
    public var maxTransactionHistory: Int
    
    /// Whether to automatically reset daily totals at midnight
    public var autoResetDailyTotals: Bool
    
    /// Whether to automatically reset weekly totals on Sunday
    public var autoResetWeeklyTotals: Bool
    
    /// Whether to automatically reset monthly totals on the 1st
    public var autoResetMonthlyTotals: Bool
    
    /// Default point value for chores (if not specified)
    public var defaultChorePoints: Int16
    
    /// Whether to track points for completed chores in period totals
    public var trackCompletionInPeriods: Bool
    
    /// Whether to track points for missed chores in period totals
    public var trackMissedInPeriods: Bool
    
    /// Whether to track manual adjustments in period totals
    public var trackAdjustmentsInPeriods: Bool
    
    // MARK: - Initialization
    
    /// Initialize with default values
    public init(
        allowNegativeBalances: Bool = false,
        maxTransactionHistory: Int = 1000,
        autoResetDailyTotals: Bool = true,
        autoResetWeeklyTotals: Bool = true,
        autoResetMonthlyTotals: Bool = true,
        defaultChorePoints: Int16 = 10,
        trackCompletionInPeriods: Bool = true,
        trackMissedInPeriods: Bool = false,
        trackAdjustmentsInPeriods: Bool = true
    ) {
        self.allowNegativeBalances = allowNegativeBalances
        self.maxTransactionHistory = maxTransactionHistory
        self.autoResetDailyTotals = autoResetDailyTotals
        self.autoResetWeeklyTotals = autoResetWeeklyTotals
        self.autoResetMonthlyTotals = autoResetMonthlyTotals
        self.defaultChorePoints = defaultChorePoints
        self.trackCompletionInPeriods = trackCompletionInPeriods
        self.trackMissedInPeriods = trackMissedInPeriods
        self.trackAdjustmentsInPeriods = trackAdjustmentsInPeriods
    }
}

/// Period types for point tracking
public enum PointPeriod: String, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    
    /// Localized display name
    public var displayName: String {
        switch self {
        case .daily:
            return LocalizationHandler.localize("points.summary.daily")
        case .weekly:
            return LocalizationHandler.localize("points.summary.weekly")
        case .monthly:
            return LocalizationHandler.localize("points.summary.monthly")
        }
    }
}

/// Point operation types
public enum PointOperation: String, CaseIterable {
    case allocation = "allocation"
    case deduction = "deduction"
    case adjustment = "adjustment"
    case reset = "reset"
    
    /// Localized display name
    public var displayName: String {
        switch self {
        case .allocation:
            return LocalizationHandler.localize("points.transactions.types.chore_completion")
        case .deduction:
            return LocalizationHandler.localize("points.transactions.types.chore_missed")
        case .adjustment:
            return LocalizationHandler.localize("points.transactions.types.manual_adjustment")
        case .reset:
            return LocalizationHandler.localize("points.transactions.types.correction")
        }
    }
}

/// Point totals structure
public struct PointTotals {
    public let current: Int16
    public let daily: Int16
    public let weekly: Int16
    public let monthly: Int16
    
    public init(current: Int16, daily: Int16, weekly: Int16, monthly: Int16) {
        self.current = current
        self.daily = daily
        self.weekly = weekly
        self.monthly = monthly
    }
}

/// Point statistics structure
public struct PointStatistics {
    public let totalEarned: Int16
    public let totalSpent: Int16
    public let netPoints: Int16
    public let transactionCount: Int
    public let averageDaily: Double
    public let averageWeekly: Double
    public let averageMonthly: Double
    public let typeBreakdown: [String: Int]
    
    public init(
        totalEarned: Int16,
        totalSpent: Int16,
        netPoints: Int16,
        transactionCount: Int,
        averageDaily: Double,
        averageWeekly: Double,
        averageMonthly: Double,
        typeBreakdown: [String: Int]
    ) {
        self.totalEarned = totalEarned
        self.totalSpent = totalSpent
        self.netPoints = netPoints
        self.transactionCount = transactionCount
        self.averageDaily = averageDaily
        self.averageWeekly = averageWeekly
        self.averageMonthly = averageMonthly
        self.typeBreakdown = typeBreakdown
    }
}
