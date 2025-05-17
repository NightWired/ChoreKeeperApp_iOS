import Foundation
import CoreServices
import ErrorHandler

/// Mock implementation of the ChoreGeneratorProtocol for testing
public class MockChoreGenerator: ChoreGeneratorProtocol {
    // MARK: - Properties

    /// The chore scheduler
    private let choreScheduler: ChoreSchedulerProtocol

    /// The next ID to use for a chore
    private var nextId: Int64 = 1000

    // MARK: - Initialization

    /// Creates a new mock chore generator
    /// - Parameter choreScheduler: The chore scheduler to use
    public init(choreScheduler: ChoreSchedulerProtocol = MockChoreScheduler()) {
        self.choreScheduler = choreScheduler
    }

    // MARK: - ChoreGeneratorProtocol Implementation

    /// Generates chore instances for a recurring chore
    /// - Parameters:
    ///   - parentChore: The parent chore
    ///   - startDate: The start date for generation
    ///   - endDate: The end date for generation
    /// - Returns: An array of generated chore instances
    /// - Throws: An error if the chores could not be generated
    public func generateChoreInstances(
        parentChore: ChoreModel,
        startDate: Date,
        endDate: Date
    ) throws -> [ChoreModel] {
        // Validate inputs
        guard parentChore.isRecurring, let patternString = parentChore.recurringPattern else {
            throw ChoreError.invalidRecurringPattern("Parent chore must be recurring and have a pattern").toAppError()
        }

        guard let pattern = RecurringPattern.fromString(patternString) else {
            throw ChoreError.invalidRecurringPattern("Invalid recurring pattern format").toAppError()
        }

        // Generate due dates
        let dueDates = try generateDueDates(
            pattern: pattern,
            startDate: startDate,
            endDate: endDate
        )

        // Create chore instances for each due date
        var choreInstances: [ChoreModel] = []

        for dueDate in dueDates {
            let id = nextId
            nextId += 1

            let choreInstance = ChoreModel(
                id: id,
                title: parentChore.title,
                description: parentChore.description,
                points: parentChore.points,
                dueDate: dueDate,
                isRecurring: false, // Child instances are not themselves recurring
                recurringPattern: nil,
                status: .pending,
                parentChoreId: parentChore.id,
                assignedToUserId: parentChore.assignedToUserId,
                createdByUserId: parentChore.createdByUserId,
                familyId: parentChore.familyId,
                iconId: parentChore.iconId
            )

            choreInstances.append(choreInstance)
        }

        // Log the generation
        Logger.info("Generated \(choreInstances.count) chore instances", context: [
            "parentChoreId": parentChore.id,
            "startDate": startDate.description,
            "endDate": endDate.description
        ])

        return choreInstances
    }

    /// Generates the next due date for a recurring chore
    /// - Parameters:
    ///   - pattern: The recurring pattern
    ///   - fromDate: The date to start from
    /// - Returns: The next due date
    /// - Throws: An error if the next due date could not be generated
    public func generateNextDueDate(
        pattern: RecurringPattern,
        fromDate: Date
    ) throws -> Date {
        switch pattern.frequency {
        case .oneTime:
            throw ChoreError.invalidRecurringPattern("Cannot generate next due date for one-time chore").toAppError()

        case .daily:
            // For daily chores, the next due date is the next day at the specified time
            let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: fromDate)!
            guard let nextDueDate = DateUtilities.setTime(for: nextDay, hour: pattern.dueHour, minute: pattern.dueMinute) else {
                throw ChoreError.invalidRecurringPattern("Invalid due time").toAppError()
            }
            return nextDueDate

        case .weekly:
            // For weekly chores, find the next occurrence of one of the specified days of the week
            guard let daysOfWeek = pattern.daysOfWeek, !daysOfWeek.isEmpty else {
                throw ChoreError.invalidRecurringPattern("Weekly recurring pattern must specify days of the week").toAppError()
            }

            // Sort days by their proximity to the current day
            let currentDayOfWeek = DateUtilities.dayOfWeek(for: fromDate) ?? .sunday
            let sortedDays = daysOfWeek.sorted { day1, day2 in
                let diff1 = (day1.rawValue - currentDayOfWeek.rawValue + 7) % 7
                let diff2 = (day2.rawValue - currentDayOfWeek.rawValue + 7) % 7
                return diff1 < diff2
            }

            // Find the next day that occurs after fromDate
            for day in sortedDays {
                let nextOccurrence = try choreScheduler.getNextOccurrenceOfDay(dayOfWeek: day, fromDate: fromDate)
                guard let nextDueDate = DateUtilities.setTime(for: nextOccurrence, hour: pattern.dueHour, minute: pattern.dueMinute) else {
                    throw ChoreError.invalidRecurringPattern("Invalid due time").toAppError()
                }

                if nextDueDate > fromDate {
                    return nextDueDate
                }
            }

            // If we get here, we need to look at the first day in the next week
            let nextOccurrence = try choreScheduler.getNextOccurrenceOfDay(dayOfWeek: sortedDays[0], fromDate: fromDate)
            guard let nextDueDate = DateUtilities.setTime(for: nextOccurrence, hour: pattern.dueHour, minute: pattern.dueMinute) else {
                throw ChoreError.invalidRecurringPattern("Invalid due time").toAppError()
            }
            return nextDueDate

        case .monthly:
            // For monthly chores, find the next occurrence of the specified day of the month
            if pattern.useLastDayOfMonth {
                let nextOccurrence = try choreScheduler.getNextOccurrenceOfLastDayOfMonth(fromDate: fromDate)
                guard let nextDueDate = DateUtilities.setTime(for: nextOccurrence, hour: pattern.dueHour, minute: pattern.dueMinute) else {
                    throw ChoreError.invalidRecurringPattern("Invalid due time").toAppError()
                }
                return nextDueDate
            } else if let dayOfMonth = pattern.dayOfMonth {
                let nextOccurrence = try choreScheduler.getNextOccurrenceOfDayOfMonth(dayOfMonth: dayOfMonth, fromDate: fromDate)
                guard let nextDueDate = DateUtilities.setTime(for: nextOccurrence, hour: pattern.dueHour, minute: pattern.dueMinute) else {
                    throw ChoreError.invalidRecurringPattern("Invalid due time").toAppError()
                }
                return nextDueDate
            } else {
                throw ChoreError.invalidRecurringPattern("Monthly recurring pattern must specify a day of the month or use the last day of the month").toAppError()
            }
        }
    }

    /// Generates all due dates for a recurring chore within a date range
    /// - Parameters:
    ///   - pattern: The recurring pattern
    ///   - startDate: The start date
    ///   - endDate: The end date
    /// - Returns: An array of due dates
    /// - Throws: An error if the due dates could not be generated
    public func generateDueDates(
        pattern: RecurringPattern,
        startDate: Date,
        endDate: Date
    ) throws -> [Date] {
        var dueDates: [Date] = []
        var currentDate = startDate

        while currentDate <= endDate {
            let nextDueDate = try generateNextDueDate(pattern: pattern, fromDate: currentDate)

            if nextDueDate <= endDate {
                dueDates.append(nextDueDate)
                currentDate = nextDueDate
            } else {
                break
            }
        }

        return dueDates
    }

    /// Generates chore instances for all recurring chores
    /// - Parameters:
    ///   - familyId: The ID of the family to generate chores for (optional)
    ///   - endDate: The end date for generation
    /// - Returns: The number of chore instances generated
    /// - Throws: An error if the chores could not be generated
    public func generateAllRecurringChores(
        familyId: Int64?,
        endDate: Date
    ) throws -> Int {
        // This is a mock implementation that just returns a fixed number
        return 10
    }

    /// Generates chore instances for the next month
    /// - Parameter familyId: The ID of the family to generate chores for (optional)
    /// - Returns: The number of chore instances generated
    /// - Throws: An error if the chores could not be generated
    public func generateNextMonthChores(familyId: Int64?) throws -> Int {
        let endDate = DateUtilities.endOfNextMonth(for: Date())
        return try generateAllRecurringChores(familyId: familyId, endDate: endDate)
    }
}
