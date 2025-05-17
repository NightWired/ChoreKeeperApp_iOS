import Foundation
import CoreServices
import ErrorHandler
import LocalizationHandler

/// Temporary implementation of the PointAllocationServiceProtocol
/// This will be replaced by the Points module when it is implemented
public class PointAllocationService: PointAllocationServiceProtocol {
    // MARK: - Properties
    
    /// In-memory storage for point transactions
    private var pointTransactions: [PointTransaction] = []
    
    // MARK: - Initialization
    
    /// Creates a new point allocation service
    public init() {}
    
    // MARK: - PointAllocationServiceProtocol Implementation
    
    /// Allocates points for a completed chore
    /// - Parameters:
    ///   - points: The number of points to allocate
    ///   - userId: The ID of the user to allocate points to
    ///   - choreId: The ID of the chore that was completed
    ///   - completionDate: The date the chore was completed
    /// - Returns: Whether the points were successfully allocated
    /// - Throws: An error if the points could not be allocated
    public func allocatePoints(
        points: Int16,
        userId: UUID,
        choreId: Int64,
        completionDate: Date
    ) throws -> Bool {
        // Create a new point transaction
        let transaction = PointTransaction(
            id: UUID().uuidString,
            userId: userId,
            choreId: choreId,
            points: points,
            type: .completed,
            date: completionDate
        )
        
        // Add the transaction to the in-memory storage
        pointTransactions.append(transaction)
        
        // Log the allocation
        Logger.info("Allocated \(points) points to user \(userId) for chore \(choreId)")
        
        return true
    }
    
    /// Deducts points for a missed chore
    /// - Parameters:
    ///   - points: The number of points to deduct
    ///   - userId: The ID of the user to deduct points from
    ///   - choreId: The ID of the chore that was missed
    ///   - missedDate: The date the chore was missed
    /// - Returns: Whether the points were successfully deducted
    /// - Throws: An error if the points could not be deducted
    public func deductPoints(
        points: Int16,
        userId: UUID,
        choreId: Int64,
        missedDate: Date
    ) throws -> Bool {
        // Create a new point transaction
        let transaction = PointTransaction(
            id: UUID().uuidString,
            userId: userId,
            choreId: choreId,
            points: -points, // Negative points for deduction
            type: .missed,
            date: missedDate
        )
        
        // Add the transaction to the in-memory storage
        pointTransactions.append(transaction)
        
        // Log the deduction
        Logger.info("Deducted \(points) points from user \(userId) for missed chore \(choreId)")
        
        return true
    }
    
    /// Gets the total points for a user
    /// - Parameter userId: The ID of the user
    /// - Returns: The total points for the user
    /// - Throws: An error if the points could not be retrieved
    public func getTotalPoints(userId: UUID) throws -> Int {
        // Sum all point transactions for the user
        let userTransactions = pointTransactions.filter { $0.userId == userId }
        let totalPoints = userTransactions.reduce(0) { $0 + Int($1.points) }
        return totalPoints
    }
    
    /// Gets the daily points for a user
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - date: The date to get points for
    /// - Returns: The daily points for the user
    /// - Throws: An error if the points could not be retrieved
    public func getDailyPoints(userId: UUID, date: Date) throws -> Int {
        // Get the start and end of the day
        let startOfDay = DateUtilities.startOfDay(for: date)
        let endOfDay = DateUtilities.endOfDay(for: date)
        
        // Filter transactions for the user and date
        let userDailyTransactions = pointTransactions.filter {
            $0.userId == userId && $0.date >= startOfDay && $0.date <= endOfDay
        }
        
        // Sum the points
        let dailyPoints = userDailyTransactions.reduce(0) { $0 + Int($1.points) }
        return dailyPoints
    }
    
    /// Gets the weekly points for a user
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - weekStartDate: The start date of the week
    /// - Returns: The weekly points for the user
    /// - Throws: An error if the points could not be retrieved
    public func getWeeklyPoints(userId: UUID, weekStartDate: Date) throws -> Int {
        // Get the start and end of the week
        let startOfWeek = DateUtilities.startOfWeek(for: weekStartDate)
        let endOfWeek = DateUtilities.endOfWeek(for: weekStartDate)
        
        // Filter transactions for the user and week
        let userWeeklyTransactions = pointTransactions.filter {
            $0.userId == userId && $0.date >= startOfWeek && $0.date <= endOfWeek
        }
        
        // Sum the points
        let weeklyPoints = userWeeklyTransactions.reduce(0) { $0 + Int($1.points) }
        return weeklyPoints
    }
    
    /// Gets the monthly points for a user
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - month: The month (1-12)
    ///   - year: The year
    /// - Returns: The monthly points for the user
    /// - Throws: An error if the points could not be retrieved
    public func getMonthlyPoints(userId: UUID, month: Int, year: Int) throws -> Int {
        // Create a date for the first day of the month
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let date = Calendar.current.date(from: components) else {
            throw ChoreError.invalidChoreData("Invalid month or year").toAppError()
        }
        
        // Get the start and end of the month
        let startOfMonth = DateUtilities.startOfMonth(for: date)
        let endOfMonth = DateUtilities.endOfMonth(for: date)
        
        // Filter transactions for the user and month
        let userMonthlyTransactions = pointTransactions.filter {
            $0.userId == userId && $0.date >= startOfMonth && $0.date <= endOfMonth
        }
        
        // Sum the points
        let monthlyPoints = userMonthlyTransactions.reduce(0) { $0 + Int($1.points) }
        return monthlyPoints
    }
}

/// Represents a point transaction
fileprivate struct PointTransaction {
    /// The unique identifier for the transaction
    let id: String
    
    /// The ID of the user the transaction is for
    let userId: UUID
    
    /// The ID of the chore that triggered the transaction
    let choreId: Int64
    
    /// The number of points (positive for allocation, negative for deduction)
    let points: Int16
    
    /// The type of transaction
    let type: PointTransactionType
    
    /// The date of the transaction
    let date: Date
}

/// Represents the type of point transaction
fileprivate enum PointTransactionType {
    /// Points allocated for completing a chore
    case completed
    
    /// Points deducted for missing a chore
    case missed
    
    /// Points manually added by a parent
    case manualAdd
    
    /// Points manually deducted by a parent
    case manualDeduct
}
