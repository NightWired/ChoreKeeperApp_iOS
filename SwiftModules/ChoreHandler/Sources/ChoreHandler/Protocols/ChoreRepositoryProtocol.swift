import Foundation
import CoreServices
import ErrorHandler

/// Protocol defining the interface for the chore repository
public protocol ChoreRepositoryProtocol {
    /// Creates a new chore
    /// - Parameters:
    ///   - title: The title of the chore
    ///   - description: The description of the chore
    ///   - points: The points awarded for completing the chore
    ///   - dueDate: The due date for the chore
    ///   - isRecurring: Whether the chore is recurring
    ///   - recurringPattern: The recurring pattern for the chore
    ///   - status: The status of the chore
    ///   - parentChoreId: The ID of the parent chore (for recurring chores)
    ///   - assignedToUserId: The ID of the user assigned to the chore
    ///   - createdByUserId: The ID of the user who created the chore
    ///   - familyId: The ID of the family the chore belongs to
    ///   - iconId: The icon for the chore
    /// - Returns: The ID of the created chore
    /// - Throws: An error if the chore could not be created
    func createChore(
        title: String,
        description: String?,
        points: Int16,
        dueDate: Date,
        isRecurring: Bool,
        recurringPattern: String?,
        status: ChoreStatus,
        parentChoreId: Int64?,
        assignedToUserId: UUID?,
        createdByUserId: UUID?,
        familyId: Int64?,
        iconId: String
    ) throws -> Int64
    
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
    
    /// Gets all parent chores (recurring chores)
    /// - Parameter familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of parent chores
    /// - Throws: An error if the chores could not be retrieved
    func getParentChores(familyId: Int64?) throws -> [ChoreModel]
    
    /// Gets all child chores for a parent chore
    /// - Parameter parentId: The ID of the parent chore
    /// - Returns: An array of child chores
    /// - Throws: An error if the chores could not be retrieved
    func getChildChores(parentId: Int64) throws -> [ChoreModel]
    
    /// Gets all overdue chores
    /// - Parameters:
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of overdue chores
    /// - Throws: An error if the chores could not be retrieved
    func getOverdueChores(userId: UUID?, familyId: Int64?) throws -> [ChoreModel]
    
    /// Updates a chore
    /// - Parameters:
    ///   - id: The ID of the chore to update
    ///   - updates: A closure that updates the properties of the chore
    /// - Returns: Whether the chore was successfully updated
    /// - Throws: An error if the chore could not be updated
    func updateChore(
        id: Int64,
        updates: (inout ChoreModel) -> Void
    ) throws -> Bool
    
    /// Updates all future instances of a recurring chore
    /// - Parameters:
    ///   - parentId: The ID of the parent chore
    ///   - updates: A closure that updates the properties of the chores
    /// - Returns: The number of chores updated
    /// - Throws: An error if the chores could not be updated
    func updateFutureChores(
        parentId: Int64,
        updates: (inout ChoreModel) -> Void
    ) throws -> Int
    
    /// Deletes a chore
    /// - Parameter id: The ID of the chore to delete
    /// - Returns: Whether the chore was successfully deleted
    /// - Throws: An error if the chore could not be deleted
    func deleteChore(id: Int64) throws -> Bool
    
    /// Deletes all future instances of a recurring chore
    /// - Parameter parentId: The ID of the parent chore
    /// - Returns: The number of chores deleted
    /// - Throws: An error if the chores could not be deleted
    func deleteFutureChores(parentId: Int64) throws -> Int
}
