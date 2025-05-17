import Foundation

/// Protocol defining the interface for the chore validator
public protocol ChoreValidatorProtocol {
    /// Validates a chore title
    /// - Parameter title: The title to validate
    /// - Returns: Whether the title is valid
    /// - Throws: An error if the title is invalid
    func validateTitle(_ title: String) throws -> Bool
    
    /// Validates chore points
    /// - Parameter points: The points to validate
    /// - Returns: Whether the points are valid
    /// - Throws: An error if the points are invalid
    func validatePoints(_ points: Int16) throws -> Bool
    
    /// Validates a chore due date
    /// - Parameter dueDate: The due date to validate
    /// - Returns: Whether the due date is valid
    /// - Throws: An error if the due date is invalid
    func validateDueDate(_ dueDate: Date) throws -> Bool
    
    /// Validates a recurring pattern
    /// - Parameter pattern: The recurring pattern to validate
    /// - Returns: Whether the pattern is valid
    /// - Throws: An error if the pattern is invalid
    func validateRecurringPattern(_ pattern: RecurringPattern) throws -> Bool
    
    /// Validates a day of the month for monthly recurring chores
    /// - Parameter dayOfMonth: The day of the month to validate
    /// - Returns: Whether the day of the month is valid
    /// - Throws: An error if the day of the month is invalid
    func validateDayOfMonth(_ dayOfMonth: Int) throws -> Bool
    
    /// Validates days of the week for weekly recurring chores
    /// - Parameter daysOfWeek: The days of the week to validate
    /// - Returns: Whether the days of the week are valid
    /// - Throws: An error if the days of the week are invalid
    func validateDaysOfWeek(_ daysOfWeek: [DayOfWeek]) throws -> Bool
    
    /// Validates a due time string
    /// - Parameter dueTime: The due time string to validate (HH:MM format)
    /// - Returns: Whether the due time is valid
    /// - Throws: An error if the due time is invalid
    func validateDueTime(_ dueTime: String) throws -> Bool
    
    /// Validates whether a user can complete a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Returns: Whether the user can complete the chore
    /// - Throws: An error if the user cannot complete the chore
    func validateCanComplete(chore: ChoreModel, userId: UUID) throws -> Bool
    
    /// Validates whether a user can verify a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Returns: Whether the user can verify the chore
    /// - Throws: An error if the user cannot verify the chore
    func validateCanVerify(chore: ChoreModel, userId: UUID) throws -> Bool
    
    /// Validates whether a user can reject a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Returns: Whether the user can reject the chore
    /// - Throws: An error if the user cannot reject the chore
    func validateCanReject(chore: ChoreModel, userId: UUID) throws -> Bool
    
    /// Validates whether a user can update a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Returns: Whether the user can update the chore
    /// - Throws: An error if the user cannot update the chore
    func validateCanUpdate(chore: ChoreModel, userId: UUID) throws -> Bool
    
    /// Validates whether a user can delete a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Returns: Whether the user can delete the chore
    /// - Throws: An error if the user cannot delete the chore
    func validateCanDelete(chore: ChoreModel, userId: UUID) throws -> Bool
    
    /// Checks if verification is required for a chore
    /// - Parameters:
    ///   - userId: The ID of the user assigned to the chore
    ///   - familyId: The ID of the family the chore belongs to
    /// - Returns: Whether verification is required
    /// - Throws: An error if the verification requirement could not be determined
    func isVerificationRequired(userId: UUID, familyId: Int64?) throws -> Bool
}
