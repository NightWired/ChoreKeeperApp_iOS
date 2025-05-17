import Foundation

/// Protocol defining the interface for the chore scheduler
public protocol ChoreSchedulerProtocol {
    /// Schedules a chore for a specific date
    /// - Parameters:
    ///   - choreId: The ID of the chore to schedule
    ///   - dueDate: The due date for the chore
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be scheduled
    func scheduleChore(choreId: Int64, dueDate: Date) throws -> ChoreModel
    
    /// Reschedules a chore
    /// - Parameters:
    ///   - choreId: The ID of the chore to reschedule
    ///   - dueDate: The new due date for the chore
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be rescheduled
    func rescheduleChore(choreId: Int64, dueDate: Date) throws -> ChoreModel
    
    /// Gets the end date for generating recurring chores
    /// - Returns: The end date for generating recurring chores
    /// - Throws: An error if the end date could not be determined
    func getRecurringChoreEndDate() throws -> Date
    
    /// Checks if it's time to generate chores for the next month
    /// - Returns: Whether it's time to generate chores for the next month
    /// - Throws: An error if the check could not be performed
    func shouldGenerateNextMonthChores() throws -> Bool
    
    /// Gets all chores that are overdue
    /// - Parameters:
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of overdue chores
    /// - Throws: An error if the overdue chores could not be retrieved
    func getOverdueChores(userId: UUID?, familyId: Int64?) throws -> [ChoreModel]
    
    /// Gets the last day of a month
    /// - Parameters:
    ///   - month: The month (1-12)
    ///   - year: The year
    /// - Returns: The last day of the month
    /// - Throws: An error if the last day could not be determined
    func getLastDayOfMonth(month: Int, year: Int) throws -> Int
    
    /// Gets the next occurrence of a day of the week
    /// - Parameters:
    ///   - dayOfWeek: The day of the week
    ///   - fromDate: The date to start from
    /// - Returns: The next occurrence of the day of the week
    /// - Throws: An error if the next occurrence could not be determined
    func getNextOccurrenceOfDay(dayOfWeek: DayOfWeek, fromDate: Date) throws -> Date
    
    /// Gets the next occurrence of a day of the month
    /// - Parameters:
    ///   - dayOfMonth: The day of the month
    ///   - fromDate: The date to start from
    /// - Returns: The next occurrence of the day of the month
    /// - Throws: An error if the next occurrence could not be determined
    func getNextOccurrenceOfDayOfMonth(dayOfMonth: Int, fromDate: Date) throws -> Date
    
    /// Gets the next occurrence of the last day of the month
    /// - Parameter fromDate: The date to start from
    /// - Returns: The next occurrence of the last day of the month
    /// - Throws: An error if the next occurrence could not be determined
    func getNextOccurrenceOfLastDayOfMonth(fromDate: Date) throws -> Date
}
