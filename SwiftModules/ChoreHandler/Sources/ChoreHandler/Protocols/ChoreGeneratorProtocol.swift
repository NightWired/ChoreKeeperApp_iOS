import Foundation

/// Protocol defining the interface for the chore generator
public protocol ChoreGeneratorProtocol {
    /// Generates chore instances for a recurring chore
    /// - Parameters:
    ///   - parentChore: The parent chore
    ///   - startDate: The start date for generation
    ///   - endDate: The end date for generation
    /// - Returns: An array of generated chore instances
    /// - Throws: An error if the chores could not be generated
    func generateChoreInstances(
        parentChore: ChoreModel,
        startDate: Date,
        endDate: Date
    ) throws -> [ChoreModel]
    
    /// Generates the next due date for a recurring chore
    /// - Parameters:
    ///   - pattern: The recurring pattern
    ///   - fromDate: The date to start from
    /// - Returns: The next due date
    /// - Throws: An error if the next due date could not be generated
    func generateNextDueDate(
        pattern: RecurringPattern,
        fromDate: Date
    ) throws -> Date
    
    /// Generates all due dates for a recurring chore within a date range
    /// - Parameters:
    ///   - pattern: The recurring pattern
    ///   - startDate: The start date
    ///   - endDate: The end date
    /// - Returns: An array of due dates
    /// - Throws: An error if the due dates could not be generated
    func generateDueDates(
        pattern: RecurringPattern,
        startDate: Date,
        endDate: Date
    ) throws -> [Date]
    
    /// Generates chore instances for all recurring chores
    /// - Parameters:
    ///   - familyId: The ID of the family to generate chores for (optional)
    ///   - endDate: The end date for generation
    /// - Returns: The number of chore instances generated
    /// - Throws: An error if the chores could not be generated
    func generateAllRecurringChores(
        familyId: Int64?,
        endDate: Date
    ) throws -> Int
    
    /// Generates chore instances for the next month
    /// - Parameter familyId: The ID of the family to generate chores for (optional)
    /// - Returns: The number of chore instances generated
    /// - Throws: An error if the chores could not be generated
    func generateNextMonthChores(familyId: Int64?) throws -> Int
}
