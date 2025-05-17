import Foundation

/// Protocol defining the interface for the point allocation service
/// This is a temporary implementation until the Points module is created
public protocol PointAllocationServiceProtocol {
    /// Allocates points for a completed chore
    /// - Parameters:
    ///   - points: The number of points to allocate
    ///   - userId: The ID of the user to allocate points to
    ///   - choreId: The ID of the chore that was completed
    ///   - completionDate: The date the chore was completed
    /// - Returns: Whether the points were successfully allocated
    /// - Throws: An error if the points could not be allocated
    func allocatePoints(
        points: Int16,
        userId: UUID,
        choreId: Int64,
        completionDate: Date
    ) throws -> Bool
    
    /// Deducts points for a missed chore
    /// - Parameters:
    ///   - points: The number of points to deduct
    ///   - userId: The ID of the user to deduct points from
    ///   - choreId: The ID of the chore that was missed
    ///   - missedDate: The date the chore was missed
    /// - Returns: Whether the points were successfully deducted
    /// - Throws: An error if the points could not be deducted
    func deductPoints(
        points: Int16,
        userId: UUID,
        choreId: Int64,
        missedDate: Date
    ) throws -> Bool
    
    /// Gets the total points for a user
    /// - Parameter userId: The ID of the user
    /// - Returns: The total points for the user
    /// - Throws: An error if the points could not be retrieved
    func getTotalPoints(userId: UUID) throws -> Int
    
    /// Gets the daily points for a user
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - date: The date to get points for
    /// - Returns: The daily points for the user
    /// - Throws: An error if the points could not be retrieved
    func getDailyPoints(userId: UUID, date: Date) throws -> Int
    
    /// Gets the weekly points for a user
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - weekStartDate: The start date of the week
    /// - Returns: The weekly points for the user
    /// - Throws: An error if the points could not be retrieved
    func getWeeklyPoints(userId: UUID, weekStartDate: Date) throws -> Int
    
    /// Gets the monthly points for a user
    /// - Parameters:
    ///   - userId: The ID of the user
    ///   - month: The month (1-12)
    ///   - year: The year
    /// - Returns: The monthly points for the user
    /// - Throws: An error if the points could not be retrieved
    func getMonthlyPoints(userId: UUID, month: Int, year: Int) throws -> Int
}
