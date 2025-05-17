import Foundation

/// Protocol defining the interface for the chore service
public protocol ChoreServiceProtocol {
    /// Creates a new chore
    /// - Parameters:
    ///   - title: The title of the chore
    ///   - description: The description of the chore
    ///   - points: The points awarded for completing the chore
    ///   - dueDate: The due date for the chore
    ///   - isRecurring: Whether the chore is recurring
    ///   - recurringPattern: The recurring pattern for the chore
    ///   - assignedToUserId: The ID of the user assigned to the chore
    ///   - createdByUserId: The ID of the user who created the chore
    ///   - familyId: The ID of the family the chore belongs to
    ///   - iconId: The icon for the chore
    /// - Returns: The created chore
    /// - Throws: An error if the chore could not be created
    func createChore(
        title: String,
        description: String?,
        points: Int16,
        dueDate: Date,
        isRecurring: Bool,
        recurringPattern: String?,
        assignedToUserId: UUID?,
        createdByUserId: UUID?,
        familyId: Int64?,
        iconId: String
    ) throws -> ChoreModel
    
    /// Creates a one-time chore
    /// - Parameters:
    ///   - title: The title of the chore
    ///   - description: The description of the chore
    ///   - points: The points awarded for completing the chore
    ///   - dueDate: The due date for the chore
    ///   - assignedToUserId: The ID of the user assigned to the chore
    ///   - createdByUserId: The ID of the user who created the chore
    ///   - familyId: The ID of the family the chore belongs to
    ///   - iconId: The icon for the chore
    /// - Returns: The created chore
    /// - Throws: An error if the chore could not be created
    func createOneTimeChore(
        title: String,
        description: String?,
        points: Int16,
        dueDate: Date,
        assignedToUserId: UUID?,
        createdByUserId: UUID?,
        familyId: Int64?,
        iconId: String
    ) throws -> ChoreModel
    
    /// Creates a recurring chore
    /// - Parameters:
    ///   - title: The title of the chore
    ///   - description: The description of the chore
    ///   - points: The points awarded for completing the chore
    ///   - frequency: The frequency of the recurring chore
    ///   - daysOfWeek: The days of the week for weekly recurring chores
    ///   - dayOfMonth: The day of the month for monthly recurring chores
    ///   - useLastDayOfMonth: Whether to use the last day of the month for monthly recurring chores
    ///   - dueTime: The time of day for the chore to be due (HH:MM format)
    ///   - assignedToUserId: The ID of the user assigned to the chore
    ///   - createdByUserId: The ID of the user who created the chore
    ///   - familyId: The ID of the family the chore belongs to
    ///   - iconId: The icon for the chore
    /// - Returns: The created parent chore and its child instances
    /// - Throws: An error if the chore could not be created
    func createRecurringChore(
        title: String,
        description: String?,
        points: Int16,
        frequency: ChoreFrequency,
        daysOfWeek: [DayOfWeek]?,
        dayOfMonth: Int?,
        useLastDayOfMonth: Bool,
        dueTime: String,
        assignedToUserId: UUID?,
        createdByUserId: UUID?,
        familyId: Int64?,
        iconId: String
    ) throws -> (parent: ChoreModel, children: [ChoreModel])
    
    /// Gets a chore by ID
    /// - Parameter id: The ID of the chore to get
    /// - Returns: The chore, or nil if not found
    /// - Throws: An error if the chore could not be retrieved
    func getChore(id: Int64) throws -> ChoreModel?
    
    /// Gets all chores for a user
    /// - Parameter userId: The ID of the user
    /// - Returns: An array of chores assigned to the user
    /// - Throws: An error if the chores could not be retrieved
    func getChoresForUser(userId: UUID) throws -> [ChoreModel]
    
    /// Gets all chores for a family
    /// - Parameter familyId: The ID of the family
    /// - Returns: An array of chores for the family
    /// - Throws: An error if the chores could not be retrieved
    func getChoresForFamily(familyId: Int64) throws -> [ChoreModel]
    
    /// Gets all chores with a specific status
    /// - Parameters:
    ///   - status: The status to filter by
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of chores with the specified status
    /// - Throws: An error if the chores could not be retrieved
    func getChoresByStatus(
        status: ChoreStatus,
        userId: UUID?,
        familyId: Int64?
    ) throws -> [ChoreModel]
    
    /// Gets all chores due on a specific date
    /// - Parameters:
    ///   - date: The date to filter by
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of chores due on the specified date
    /// - Throws: An error if the chores could not be retrieved
    func getChoresDueOn(
        date: Date,
        userId: UUID?,
        familyId: Int64?
    ) throws -> [ChoreModel]
    
    /// Gets all chores due between two dates
    /// - Parameters:
    ///   - startDate: The start date
    ///   - endDate: The end date
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of chores due between the specified dates
    /// - Throws: An error if the chores could not be retrieved
    func getChoresDueBetween(
        startDate: Date,
        endDate: Date,
        userId: UUID?,
        familyId: Int64?
    ) throws -> [ChoreModel]
    
    /// Updates a chore
    /// - Parameters:
    ///   - id: The ID of the chore to update
    ///   - updates: A closure that updates the properties of the chore
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be updated
    func updateChore(
        id: Int64,
        updates: (inout ChoreModel) -> Void
    ) throws -> ChoreModel
    
    /// Updates all future instances of a recurring chore
    /// - Parameters:
    ///   - parentId: The ID of the parent chore
    ///   - updates: A closure that updates the properties of the chores
    /// - Returns: The updated chores
    /// - Throws: An error if the chores could not be updated
    func updateFutureChores(
        parentId: Int64,
        updates: (inout ChoreModel) -> Void
    ) throws -> [ChoreModel]
    
    /// Deletes a chore
    /// - Parameter id: The ID of the chore to delete
    /// - Throws: An error if the chore could not be deleted
    func deleteChore(id: Int64) throws
    
    /// Deletes all future instances of a recurring chore
    /// - Parameter parentId: The ID of the parent chore
    /// - Throws: An error if the chores could not be deleted
    func deleteFutureChores(parentId: Int64) throws
    
    /// Marks a chore as completed
    /// - Parameters:
    ///   - id: The ID of the chore to mark as completed
    ///   - completedByUserId: The ID of the user who completed the chore
    ///   - requireVerification: Whether the chore requires verification
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be marked as completed
    func completeChore(
        id: Int64,
        completedByUserId: UUID,
        requireVerification: Bool
    ) throws -> ChoreModel
    
    /// Verifies a completed chore
    /// - Parameters:
    ///   - id: The ID of the chore to verify
    ///   - verifiedByUserId: The ID of the user who verified the chore
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be verified
    func verifyChore(
        id: Int64,
        verifiedByUserId: UUID
    ) throws -> ChoreModel
    
    /// Rejects a completed chore
    /// - Parameters:
    ///   - id: The ID of the chore to reject
    ///   - rejectedByUserId: The ID of the user who rejected the chore
    ///   - reason: The reason for rejection
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be rejected
    func rejectChore(
        id: Int64,
        rejectedByUserId: UUID,
        reason: String?
    ) throws -> ChoreModel
    
    /// Marks a chore as missed
    /// - Parameter id: The ID of the chore to mark as missed
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be marked as missed
    func markChoreMissed(id: Int64) throws -> ChoreModel
    
    /// Checks for overdue chores and marks them as missed
    /// - Returns: The number of chores marked as missed
    /// - Throws: An error if the chores could not be checked
    func checkOverdueChores() throws -> Int
    
    /// Generates recurring chore instances for the next period
    /// - Returns: The number of chore instances generated
    /// - Throws: An error if the chores could not be generated
    func generateRecurringChores() throws -> Int
}
