import Foundation
import CoreServices
import ErrorHandler
import LocalizationHandler

/// Mock implementation of the ChoreValidatorProtocol for testing
public class MockChoreValidator: ChoreValidatorProtocol {
    // MARK: - Properties

    /// The localization service
    private let localizationService: LocalizationServiceProtocol

    /// Whether verification is required for chores
    private var verificationRequired: Bool = true

    /// User IDs that are considered parents
    private var parentUserIds: Set<UUID> = []

    // MARK: - Initialization

    /// Creates a new mock chore validator
    public init() {
        self.localizationService = LocalizationHandler.shared

        // Add some test parent user IDs
        parentUserIds.insert(UUID())
    }

    /// Sets whether verification is required for chores
    /// - Parameter required: Whether verification is required
    public func setVerificationRequired(_ required: Bool) {
        verificationRequired = required
    }

    /// Adds a parent user ID
    /// - Parameter userId: The user ID to add
    public func addParentUserId(_ userId: UUID) {
        parentUserIds.insert(userId)
    }

    // MARK: - ChoreValidatorProtocol Implementation

    /// Validates a chore title
    /// - Parameter title: The title to validate
    /// - Returns: Whether the title is valid
    /// - Throws: An error if the title is invalid
    public func validateTitle(_ title: String) throws -> Bool {
        // Title must not be empty
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ChoreError.invalidTitle("Title cannot be empty").toAppError()
        }

        // Title must not be too long
        if title.count > 100 {
            throw ChoreError.invalidTitle("Title cannot be longer than 100 characters").toAppError()
        }

        return true
    }

    /// Validates chore points
    /// - Parameter points: The points to validate
    /// - Returns: Whether the points are valid
    /// - Throws: An error if the points are invalid
    public func validatePoints(_ points: Int16) throws -> Bool {
        // Points must be positive
        if points <= 0 {
            throw ChoreError.invalidPoints("Points must be greater than 0").toAppError()
        }

        // Points must not be too high
        if points > 1000 {
            throw ChoreError.invalidPoints("Points cannot be greater than 1000").toAppError()
        }

        return true
    }

    /// Validates a chore due date
    /// - Parameter dueDate: The due date to validate
    /// - Returns: Whether the due date is valid
    /// - Throws: An error if the due date is invalid
    public func validateDueDate(_ dueDate: Date) throws -> Bool {
        // Due date must not be in the past
        if dueDate < Date() {
            throw ChoreError.invalidDueDate("Due date cannot be in the past").toAppError()
        }

        // Due date must not be too far in the future
        let maxDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        if dueDate > maxDate {
            throw ChoreError.invalidDueDate("Due date cannot be more than 1 year in the future").toAppError()
        }

        return true
    }

    /// Validates a recurring pattern
    /// - Parameter pattern: The recurring pattern to validate
    /// - Returns: Whether the pattern is valid
    /// - Throws: An error if the pattern is invalid
    public func validateRecurringPattern(_ pattern: RecurringPattern) throws -> Bool {
        switch pattern.frequency {
        case .oneTime:
            // One-time chores don't have a recurring pattern
            return true

        case .daily:
            // Daily chores just need a valid due time
            return try validateDueTime(pattern.dueHour, pattern.dueMinute)

        case .weekly:
            // Weekly chores need valid days of the week and a due time
            guard let daysOfWeek = pattern.daysOfWeek, !daysOfWeek.isEmpty else {
                throw ChoreError.invalidRecurringPattern("Weekly recurring pattern must specify days of the week").toAppError()
            }

            _ = try validateDaysOfWeek(daysOfWeek)
            return try validateDueTime(pattern.dueHour, pattern.dueMinute)

        case .monthly:
            // Monthly chores need either a valid day of the month or to use the last day of the month,
            // and a due time
            if pattern.useLastDayOfMonth {
                return try validateDueTime(pattern.dueHour, pattern.dueMinute)
            } else if let dayOfMonth = pattern.dayOfMonth {
                _ = try validateDayOfMonth(dayOfMonth)
                return try validateDueTime(pattern.dueHour, pattern.dueMinute)
            } else {
                throw ChoreError.invalidRecurringPattern("Monthly recurring pattern must specify a day of the month or use the last day of the month").toAppError()
            }
        }
    }

    /// Validates a day of the month for monthly recurring chores
    /// - Parameter dayOfMonth: The day of the month to validate
    /// - Returns: Whether the day of the month is valid
    /// - Throws: An error if the day of the month is invalid
    public func validateDayOfMonth(_ dayOfMonth: Int) throws -> Bool {
        // Day of month must be between 1 and 31
        if dayOfMonth < 1 || dayOfMonth > 31 {
            throw ChoreError.invalidRecurringPattern("Day of month must be between 1 and 31").toAppError()
        }

        return true
    }

    /// Validates days of the week for weekly recurring chores
    /// - Parameter daysOfWeek: The days of the week to validate
    /// - Returns: Whether the days of the week are valid
    /// - Throws: An error if the days of the week are invalid
    public func validateDaysOfWeek(_ daysOfWeek: [DayOfWeek]) throws -> Bool {
        // Must have at least one day of the week
        if daysOfWeek.isEmpty {
            throw ChoreError.invalidRecurringPattern("Weekly recurring pattern must specify at least one day of the week").toAppError()
        }

        // Days of the week must be unique
        let uniqueDays = Set(daysOfWeek)
        if uniqueDays.count != daysOfWeek.count {
            throw ChoreError.invalidRecurringPattern("Days of the week must be unique").toAppError()
        }

        return true
    }

    /// Validates a due time string
    /// - Parameter dueTime: The due time string to validate (HH:MM format)
    /// - Returns: Whether the due time is valid
    /// - Throws: An error if the due time is invalid
    public func validateDueTime(_ dueTime: String) throws -> Bool {
        // Due time must be in HH:MM format
        guard DateUtilities.parseTimeString(dueTime) != nil else {
            throw ChoreError.invalidRecurringPattern("Due time must be in HH:MM format").toAppError()
        }

        return true
    }

    /// Validates due time hours and minutes
    /// - Parameters:
    ///   - hour: The hour (0-23)
    ///   - minute: The minute (0-59)
    /// - Returns: Whether the due time is valid
    /// - Throws: An error if the due time is invalid
    public func validateDueTime(_ hour: Int, _ minute: Int) throws -> Bool {
        // Hours must be between 0 and 23
        if hour < 0 || hour > 23 {
            throw ChoreError.invalidRecurringPattern("Hour must be between 0 and 23").toAppError()
        }

        // Minutes must be between 0 and 59
        if minute < 0 || minute > 59 {
            throw ChoreError.invalidRecurringPattern("Minute must be between 0 and 59").toAppError()
        }

        return true
    }

    /// Validates whether a user can complete a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Returns: Whether the user can complete the chore
    /// - Throws: An error if the user cannot complete the chore
    public func validateCanComplete(chore: ChoreModel, userId: UUID) throws -> Bool {
        // Chore must be pending or rejected
        if !chore.canBeCompleted {
            throw ChoreError.invalidStatus("Chore must be pending or rejected to be completed").toAppError()
        }

        // User must be assigned to the chore
        if let assignedUserId = chore.assignedToUserId, assignedUserId != userId {
            throw ChoreError.permissionDenied("Only the assigned user can complete this chore").toAppError()
        }

        return true
    }

    /// Validates whether a user can verify a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Returns: Whether the user can verify the chore
    /// - Throws: An error if the user cannot verify the chore
    public func validateCanVerify(chore: ChoreModel, userId: UUID) throws -> Bool {
        // Chore must be pending verification
        if !chore.canBeVerified {
            throw ChoreError.invalidStatus("Chore must be pending verification to be verified").toAppError()
        }

        // User must be a parent
        if !isParent(userId) {
            throw ChoreError.permissionDenied("Only parents can verify chores").toAppError()
        }

        return true
    }

    /// Validates whether a user can reject a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Returns: Whether the user can reject the chore
    /// - Throws: An error if the user cannot reject the chore
    public func validateCanReject(chore: ChoreModel, userId: UUID) throws -> Bool {
        // Chore must be pending verification
        if !chore.canBeRejected {
            throw ChoreError.invalidStatus("Chore must be pending verification to be rejected").toAppError()
        }

        // User must be a parent
        if !isParent(userId) {
            throw ChoreError.permissionDenied("Only parents can reject chores").toAppError()
        }

        return true
    }

    /// Validates whether a user can update a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Returns: Whether the user can update the chore
    /// - Throws: An error if the user cannot update the chore
    public func validateCanUpdate(chore: ChoreModel, userId: UUID) throws -> Bool {
        // User must be a parent
        if !isParent(userId) {
            throw ChoreError.permissionDenied("Only parents can update chores").toAppError()
        }

        return true
    }

    /// Validates whether a user can delete a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Returns: Whether the user can delete the chore
    /// - Throws: An error if the user cannot delete the chore
    public func validateCanDelete(chore: ChoreModel, userId: UUID) throws -> Bool {
        // User must be a parent
        if !isParent(userId) {
            throw ChoreError.permissionDenied("Only parents can delete chores").toAppError()
        }

        return true
    }

    /// Checks if verification is required for a chore
    /// - Parameters:
    ///   - userId: The ID of the user assigned to the chore
    ///   - familyId: The ID of the family the chore belongs to
    /// - Returns: Whether verification is required
    /// - Throws: An error if the verification requirement could not be determined
    public func isVerificationRequired(userId: UUID, familyId: Int64?) throws -> Bool {
        return verificationRequired
    }

    // MARK: - Private Methods

    /// Checks if a user is a parent
    /// - Parameter userId: The ID of the user to check
    /// - Returns: Whether the user is a parent
    private func isParent(_ userId: UUID) -> Bool {
        return parentUserIds.contains(userId)
    }
}
