import Foundation
import CoreServices
import ErrorHandler

/// Mock implementation of the ChoreSchedulerProtocol for testing
public class MockChoreScheduler: ChoreSchedulerProtocol {
    // MARK: - Properties

    /// In-memory storage for chores
    private var chores: [ChoreModel] = []

    /// Whether it's time to generate chores for the next month
    private var shouldGenerateNextMonth: Bool = false

    // MARK: - Initialization

    /// Creates a new mock chore scheduler
    public init() {}

    /// Sets the chores for the mock scheduler
    /// - Parameter chores: The chores to set
    public func setChores(_ chores: [ChoreModel]) {
        self.chores = chores
    }

    /// Sets whether it's time to generate chores for the next month
    /// - Parameter shouldGenerate: Whether it's time to generate chores for the next month
    public func setShouldGenerateNextMonth(_ shouldGenerate: Bool) {
        shouldGenerateNextMonth = shouldGenerate
    }

    // MARK: - ChoreSchedulerProtocol Implementation

    /// Schedules a chore for a specific date
    /// - Parameters:
    ///   - choreId: The ID of the chore to schedule
    ///   - dueDate: The due date for the chore
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be scheduled
    public func scheduleChore(choreId: Int64, dueDate: Date) throws -> ChoreModel {
        // Find the chore
        guard let index = chores.firstIndex(where: { $0.id == choreId }) else {
            throw ChoreError.choreNotFound(choreId).toAppError()
        }

        // Update the chore
        var updatedChore = chores[index]
        updatedChore = updatedChore.copy { chore in
            var mutableChore = chore
            mutableChore.dueDate = dueDate
        }
        chores[index] = updatedChore

        return updatedChore
    }

    /// Reschedules a chore
    /// - Parameters:
    ///   - choreId: The ID of the chore to reschedule
    ///   - dueDate: The new due date for the chore
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be rescheduled
    public func rescheduleChore(choreId: Int64, dueDate: Date) throws -> ChoreModel {
        return try scheduleChore(choreId: choreId, dueDate: dueDate)
    }

    /// Gets the end date for generating recurring chores
    /// - Returns: The end date for generating recurring chores
    /// - Throws: An error if the end date could not be determined
    public func getRecurringChoreEndDate() throws -> Date {
        // Generate chores up to the end of the next month
        return DateUtilities.endOfNextMonth(for: Date())
    }

    /// Checks if it's time to generate chores for the next month
    /// - Returns: Whether it's time to generate chores for the next month
    /// - Throws: An error if the check could not be performed
    public func shouldGenerateNextMonthChores() throws -> Bool {
        return shouldGenerateNextMonth
    }

    /// Gets all chores that are overdue
    /// - Parameters:
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of overdue chores
    /// - Throws: An error if the overdue chores could not be retrieved
    public func getOverdueChores(userId: UUID?, familyId: Int64?) throws -> [ChoreModel] {
        let now = Date()

        return chores.filter { chore in
            var matches = chore.status == .pending && chore.dueDate < now

            if let userId = userId {
                matches = matches && chore.assignedToUserId == userId
            }

            if let familyId = familyId {
                matches = matches && chore.familyId == familyId
            }

            return matches
        }
    }

    /// Gets the last day of a month
    /// - Parameters:
    ///   - month: The month (1-12)
    ///   - year: The year
    /// - Returns: The last day of the month
    /// - Throws: An error if the last day could not be determined
    public func getLastDayOfMonth(month: Int, year: Int) throws -> Int {
        return DateUtilities.lastDayOfMonth(month: month, year: year)
    }

    /// Gets the next occurrence of a day of the week
    /// - Parameters:
    ///   - dayOfWeek: The day of the week
    ///   - fromDate: The date to start from
    /// - Returns: The next occurrence of the day of the week
    /// - Throws: An error if the next occurrence could not be determined
    public func getNextOccurrenceOfDay(dayOfWeek: DayOfWeek, fromDate: Date) throws -> Date {
        return DateUtilities.nextOccurrenceOfDay(dayOfWeek: dayOfWeek, fromDate: fromDate)
    }

    /// Gets the next occurrence of a day of the month
    /// - Parameters:
    ///   - dayOfMonth: The day of the month
    ///   - fromDate: The date to start from
    /// - Returns: The next occurrence of the day of the month
    /// - Throws: An error if the next occurrence could not be determined
    public func getNextOccurrenceOfDayOfMonth(dayOfMonth: Int, fromDate: Date) throws -> Date {
        return DateUtilities.nextOccurrenceOfDayOfMonth(dayOfMonth: dayOfMonth, fromDate: fromDate)
    }

    /// Gets the next occurrence of the last day of the month
    /// - Parameter fromDate: The date to start from
    /// - Returns: The next occurrence of the last day of the month
    /// - Throws: An error if the next occurrence could not be determined
    public func getNextOccurrenceOfLastDayOfMonth(fromDate: Date) throws -> Date {
        return DateUtilities.nextOccurrenceOfLastDayOfMonth(fromDate: fromDate)
    }
}
