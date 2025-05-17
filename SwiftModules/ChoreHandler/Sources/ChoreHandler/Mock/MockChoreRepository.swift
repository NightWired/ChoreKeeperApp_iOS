import Foundation
import CoreServices
import ErrorHandler

/// Mock implementation of the ChoreRepositoryProtocol for testing
public class MockChoreRepository: ChoreRepositoryProtocol {
    // MARK: - Properties
    
    /// In-memory storage for chores
    private var chores: [ChoreModel] = []
    
    /// The next ID to use for a chore
    private var nextId: Int64 = 1
    
    // MARK: - Initialization
    
    /// Creates a new mock chore repository
    public init() {
        // Add some test data
        createTestData()
    }
    
    // MARK: - ChoreRepositoryProtocol Implementation
    
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
    public func createChore(
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
    ) throws -> Int64 {
        let id = nextId
        nextId += 1
        
        let chore = ChoreModel(
            id: id,
            title: title,
            description: description,
            points: points,
            dueDate: dueDate,
            isRecurring: isRecurring,
            recurringPattern: recurringPattern,
            status: status,
            parentChoreId: parentChoreId,
            assignedToUserId: assignedToUserId,
            createdByUserId: createdByUserId,
            familyId: familyId,
            iconId: iconId
        )
        
        chores.append(chore)
        
        return id
    }
    
    /// Gets a chore by ID
    /// - Parameter id: The ID of the chore to get
    /// - Returns: The chore, or nil if not found
    /// - Throws: An error if the chore could not be retrieved
    public func getChore(id: Int64) throws -> ChoreModel? {
        return chores.first { $0.id == id }
    }
    
    /// Gets all chores for a user
    /// - Parameter userId: The ID of the user
    /// - Returns: An array of chores assigned to the user
    /// - Throws: An error if the chores could not be retrieved
    public func getChoresForUser(userId: UUID) throws -> [ChoreModel] {
        return chores.filter { $0.assignedToUserId == userId }
    }
    
    /// Gets all chores for a family
    /// - Parameter familyId: The ID of the family
    /// - Returns: An array of chores for the family
    /// - Throws: An error if the chores could not be retrieved
    public func getChoresForFamily(familyId: Int64) throws -> [ChoreModel] {
        return chores.filter { $0.familyId == familyId }
    }
    
    /// Gets all chores with a specific status
    /// - Parameters:
    ///   - status: The status to filter by
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of chores with the specified status
    /// - Throws: An error if the chores could not be retrieved
    public func getChoresByStatus(
        status: ChoreStatus,
        userId: UUID?,
        familyId: Int64?
    ) throws -> [ChoreModel] {
        return chores.filter { chore in
            var matches = chore.status == status
            
            if let userId = userId {
                matches = matches && chore.assignedToUserId == userId
            }
            
            if let familyId = familyId {
                matches = matches && chore.familyId == familyId
            }
            
            return matches
        }
    }
    
    /// Gets all chores due on a specific date
    /// - Parameters:
    ///   - date: The date to filter by
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of chores due on the specified date
    /// - Throws: An error if the chores could not be retrieved
    public func getChoresDueOn(
        date: Date,
        userId: UUID?,
        familyId: Int64?
    ) throws -> [ChoreModel] {
        let startOfDay = DateUtilities.startOfDay(for: date)
        let endOfDay = DateUtilities.endOfDay(for: date)
        
        return chores.filter { chore in
            var matches = chore.dueDate >= startOfDay && chore.dueDate <= endOfDay
            
            if let userId = userId {
                matches = matches && chore.assignedToUserId == userId
            }
            
            if let familyId = familyId {
                matches = matches && chore.familyId == familyId
            }
            
            return matches
        }
    }
    
    /// Gets all chores due between two dates
    /// - Parameters:
    ///   - startDate: The start date
    ///   - endDate: The end date
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of chores due between the specified dates
    /// - Throws: An error if the chores could not be retrieved
    public func getChoresDueBetween(
        startDate: Date,
        endDate: Date,
        userId: UUID?,
        familyId: Int64?
    ) throws -> [ChoreModel] {
        return chores.filter { chore in
            var matches = chore.dueDate >= startDate && chore.dueDate <= endDate
            
            if let userId = userId {
                matches = matches && chore.assignedToUserId == userId
            }
            
            if let familyId = familyId {
                matches = matches && chore.familyId == familyId
            }
            
            return matches
        }
    }
    
    /// Gets all parent chores (recurring chores)
    /// - Parameter familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of parent chores
    /// - Throws: An error if the chores could not be retrieved
    public func getParentChores(familyId: Int64?) throws -> [ChoreModel] {
        return chores.filter { chore in
            var matches = chore.isRecurring && chore.parentChoreId == nil
            
            if let familyId = familyId {
                matches = matches && chore.familyId == familyId
            }
            
            return matches
        }
    }
    
    /// Gets all child chores for a parent chore
    /// - Parameter parentId: The ID of the parent chore
    /// - Returns: An array of child chores
    /// - Throws: An error if the chores could not be retrieved
    public func getChildChores(parentId: Int64) throws -> [ChoreModel] {
        return chores.filter { $0.parentChoreId == parentId }
    }
    
    /// Gets all overdue chores
    /// - Parameters:
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of overdue chores
    /// - Throws: An error if the chores could not be retrieved
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
    
    /// Updates a chore
    /// - Parameters:
    ///   - id: The ID of the chore to update
    ///   - updates: A closure that updates the properties of the chore
    /// - Returns: Whether the chore was successfully updated
    /// - Throws: An error if the chore could not be updated
    public func updateChore(
        id: Int64,
        updates: (inout ChoreModel) -> Void
    ) throws -> Bool {
        guard let index = chores.firstIndex(where: { $0.id == id }) else {
            throw ChoreError.choreNotFound(id).toAppError()
        }
        
        var updatedChore = chores[index]
        updates(&updatedChore)
        chores[index] = updatedChore
        
        return true
    }
    
    /// Updates all future instances of a recurring chore
    /// - Parameters:
    ///   - parentId: The ID of the parent chore
    ///   - updates: A closure that updates the properties of the chores
    /// - Returns: The number of chores updated
    /// - Throws: An error if the chores could not be updated
    public func updateFutureChores(
        parentId: Int64,
        updates: (inout ChoreModel) -> Void
    ) throws -> Int {
        let now = Date()
        var updateCount = 0
        
        for index in chores.indices {
            if chores[index].parentChoreId == parentId && chores[index].dueDate > now {
                var updatedChore = chores[index]
                updates(&updatedChore)
                chores[index] = updatedChore
                updateCount += 1
            }
        }
        
        return updateCount
    }
    
    /// Deletes a chore
    /// - Parameter id: The ID of the chore to delete
    /// - Returns: Whether the chore was successfully deleted
    /// - Throws: An error if the chore could not be deleted
    public func deleteChore(id: Int64) throws -> Bool {
        guard let index = chores.firstIndex(where: { $0.id == id }) else {
            throw ChoreError.choreNotFound(id).toAppError()
        }
        
        chores.remove(at: index)
        
        return true
    }
    
    /// Deletes all future instances of a recurring chore
    /// - Parameter parentId: The ID of the parent chore
    /// - Returns: The number of chores deleted
    /// - Throws: An error if the chores could not be deleted
    public func deleteFutureChores(parentId: Int64) throws -> Int {
        let now = Date()
        var deleteCount = 0
        
        chores.removeAll { chore in
            if chore.parentChoreId == parentId && chore.dueDate > now {
                deleteCount += 1
                return true
            }
            return false
        }
        
        return deleteCount
    }
    
    // MARK: - Private Methods
    
    /// Creates test data for the mock repository
    private func createTestData() {
        // Create some test users
        let parentUserId = UUID()
        let childUserId = UUID()
        let familyId: Int64 = 1
        
        // Create some test chores
        do {
            // One-time chore
            _ = try createChore(
                title: "Clean Room",
                description: "Vacuum and dust the bedroom",
                points: 10,
                dueDate: Date().addingTimeInterval(86400), // Due tomorrow
                isRecurring: false,
                recurringPattern: nil,
                status: .pending,
                parentChoreId: nil,
                assignedToUserId: childUserId,
                createdByUserId: parentUserId,
                familyId: familyId,
                iconId: "room"
            )
            
            // Parent chore (daily)
            let dailyParentId = try createChore(
                title: "Make Bed",
                description: "Make your bed in the morning",
                points: 5,
                dueDate: Date(),
                isRecurring: true,
                recurringPattern: "daily:10:00",
                status: .pending,
                parentChoreId: nil,
                assignedToUserId: childUserId,
                createdByUserId: parentUserId,
                familyId: familyId,
                iconId: "bed"
            )
            
            // Child chores for daily parent
            for i in 1...5 {
                _ = try createChore(
                    title: "Make Bed",
                    description: "Make your bed in the morning",
                    points: 5,
                    dueDate: Date().addingTimeInterval(Double(i) * 86400),
                    isRecurring: false,
                    recurringPattern: nil,
                    status: .pending,
                    parentChoreId: dailyParentId,
                    assignedToUserId: childUserId,
                    createdByUserId: parentUserId,
                    familyId: familyId,
                    iconId: "bed"
                )
            }
            
            // Parent chore (weekly)
            let weeklyParentId = try createChore(
                title: "Take Out Trash",
                description: "Empty all trash cans and take to curb",
                points: 15,
                dueDate: Date(),
                isRecurring: true,
                recurringPattern: "weekly:1,4:18:00",
                status: .pending,
                parentChoreId: nil,
                assignedToUserId: childUserId,
                createdByUserId: parentUserId,
                familyId: familyId,
                iconId: "trash"
            )
            
            // Child chores for weekly parent
            for i in 1...4 {
                _ = try createChore(
                    title: "Take Out Trash",
                    description: "Empty all trash cans and take to curb",
                    points: 15,
                    dueDate: Date().addingTimeInterval(Double(i) * 7 * 86400),
                    isRecurring: false,
                    recurringPattern: nil,
                    status: .pending,
                    parentChoreId: weeklyParentId,
                    assignedToUserId: childUserId,
                    createdByUserId: parentUserId,
                    familyId: familyId,
                    iconId: "trash"
                )
            }
        } catch {
            Logger.error("Failed to create test data: \(error.localizedDescription)")
        }
    }
}
