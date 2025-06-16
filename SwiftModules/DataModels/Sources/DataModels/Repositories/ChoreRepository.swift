import Foundation
import CoreData
import CoreServices
import ErrorHandler

/// Repository for Chore entities
public class ChoreRepository: AbstractRepository<NSManagedObject> {

    // MARK: - Properties

    /// Shared instance of the repository
    public static let shared = ChoreRepository()

    /// The entity name
    public override class var entityName: String {
        return "Chore"
    }

    // MARK: - Public Methods

    /// Create a new chore
    /// - Parameters:
    ///   - title: The chore title
    ///   - description: The chore description
    ///   - points: Points awarded for completion
    ///   - dueDate: When the chore is due
    ///   - isRecurring: Whether the chore repeats
    ///   - recurringPattern: Pattern for recurring chores
    ///   - status: Current status of the chore
    ///   - assignedToUser: User assigned to the chore
    ///   - createdByUser: User who created the chore
    ///   - family: Family the chore belongs to
    ///   - iconId: Icon identifier for the chore
    /// - Returns: The created chore
    /// - Throws: Error if the creation fails
    public func create(
        title: String,
        description: String?,
        points: Int16,
        dueDate: Date,
        isRecurring: Bool,
        recurringPattern: String?,
        status: String = "pending",
        assignedToUser: NSManagedObject? = nil,
        createdByUser: NSManagedObject? = nil,
        family: NSManagedObject? = nil,
        iconId: String = "custom"
    ) throws -> NSManagedObject {
        let attributes: [String: Any] = [
            "id": Int64(Date().timeIntervalSince1970 * 1000),
            "title": title,
            "choreDescription": description ?? "",
            "points": points,
            "dueDate": dueDate,
            "isRecurring": isRecurring,
            "recurringPattern": recurringPattern ?? "",
            "status": status,
            "iconId": iconId,
            "createdAt": Date(),
            "updatedAt": Date()
        ]

        let chore = try create(with: attributes)

        // Set relationships
        if let assignedToUser = assignedToUser {
            chore.setValue(assignedToUser, forKey: "assignedToUser")
        }
        
        if let createdByUser = createdByUser {
            chore.setValue(createdByUser, forKey: "createdByUser")
        }
        
        if let family = family {
            chore.setValue(family, forKey: "family")
        }

        var saveError: Error?

        performOnMainContext { context in
            do {
                try context.save()
            } catch {
                saveError = error
            }
        } completion: { error in
            if let error = error {
                saveError = error
            }
        }

        if let saveError = saveError {
            Logger.error("Failed to save chore relationships: \(saveError.localizedDescription)")
            throw DataModelError.createFailed(saveError.localizedDescription)
        }

        return chore
    }

    /// Fetch chores assigned to a specific user
    /// - Parameter user: The user to fetch chores for
    /// - Returns: Array of chores assigned to the user
    /// - Throws: Error if the fetch fails
    public func fetchByAssignedUser(_ user: NSManagedObject) throws -> [NSManagedObject] {
        let userId = user.value(forKey: "id") as? UUID ?? UUID()
        let predicate = NSPredicate(format: "assignedToUser.id == %@ AND deletedAt == nil", userId as CVarArg)
        return try fetch(with: predicate)
    }

    /// Fetch chores by status
    /// - Parameters:
    ///   - status: The status to filter by
    ///   - user: Optional user to filter by
    /// - Returns: Array of chores with the specified status
    /// - Throws: Error if the fetch fails
    public func fetchByStatus(_ status: String, user: NSManagedObject? = nil) throws -> [NSManagedObject] {
        var predicateFormat = "status == %@ AND deletedAt == nil"
        var arguments: [Any] = [status]
        
        if let user = user {
            let userId = user.value(forKey: "id") as? UUID ?? UUID()
            predicateFormat += " AND assignedToUser.id == %@"
            arguments.append(userId as CVarArg)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: arguments)
        return try fetch(with: predicate)
    }

    /// Fetch chores by family
    /// - Parameter family: The family to fetch chores for
    /// - Returns: Array of chores for the family
    /// - Throws: Error if the fetch fails
    public func fetchByFamily(_ family: NSManagedObject) throws -> [NSManagedObject] {
        let familyId = family.value(forKey: "id") as? Int64 ?? 0
        let predicate = NSPredicate(format: "family.id == %lld AND deletedAt == nil", familyId)
        return try fetch(with: predicate)
    }

    /// Fetch overdue chores
    /// - Parameters:
    ///   - user: Optional user to filter by
    ///   - family: Optional family to filter by
    /// - Returns: Array of overdue chores
    /// - Throws: Error if the fetch fails
    public func fetchOverdue(user: NSManagedObject? = nil, family: NSManagedObject? = nil) throws -> [NSManagedObject] {
        var predicateFormat = "dueDate < %@ AND status IN %@ AND deletedAt == nil"
        var arguments: [Any] = [Date(), ["pending", "pendingVerification"]]
        
        if let user = user {
            let userId = user.value(forKey: "id") as? UUID ?? UUID()
            predicateFormat += " AND assignedToUser.id == %@"
            arguments.append(userId as CVarArg)
        }
        
        if let family = family {
            let familyId = family.value(forKey: "id") as? Int64 ?? 0
            predicateFormat += " AND family.id == %lld"
            arguments.append(familyId)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: arguments)
        return try fetch(with: predicate)
    }

    /// Update chore status
    /// - Parameters:
    ///   - chore: The chore to update
    ///   - status: The new status
    /// - Throws: Error if the update fails
    public func updateStatus(_ chore: NSManagedObject, status: String) throws {
        let attributes: [String: Any] = [
            "status": status,
            "updatedAt": Date()
        ]
        
        try update(chore, with: attributes)
    }

    /// Mark chore as completed
    /// - Parameters:
    ///   - chore: The chore to mark as completed
    ///   - completedAt: When the chore was completed
    /// - Throws: Error if the update fails
    public func markCompleted(_ chore: NSManagedObject, completedAt: Date = Date()) throws {
        let attributes: [String: Any] = [
            "status": "completed",
            "completedAt": completedAt,
            "updatedAt": Date()
        ]
        
        try update(chore, with: attributes)
    }

    /// Mark chore as verified
    /// - Parameters:
    ///   - chore: The chore to mark as verified
    ///   - verifiedAt: When the chore was verified
    ///   - verifiedBy: User who verified the chore
    /// - Throws: Error if the update fails
    public func markVerified(_ chore: NSManagedObject, verifiedAt: Date = Date(), verifiedBy: NSManagedObject) throws {
        let attributes: [String: Any] = [
            "status": "verified",
            "verifiedAt": verifiedAt,
            "updatedAt": Date()
        ]
        
        try update(chore, with: attributes)
        
        // Set the verifiedBy relationship
        chore.setValue(verifiedBy, forKey: "verifiedBy")
        
        var saveError: Error?

        performOnMainContext { context in
            do {
                try context.save()
            } catch {
                saveError = error
            }
        } completion: { error in
            if let error = error {
                saveError = error
            }
        }

        if let saveError = saveError {
            Logger.error("Failed to save chore verification: \(saveError.localizedDescription)")
            throw DataModelError.updateFailed(saveError.localizedDescription)
        }
    }

    /// Soft delete a chore
    /// - Parameter chore: The chore to delete
    /// - Throws: Error if the deletion fails
    public func softDelete(_ chore: NSManagedObject) throws {
        let attributes: [String: Any] = [
            "deletedAt": Date(),
            "updatedAt": Date()
        ]
        
        try update(chore, with: attributes)
    }

    /// Get chores due within a date range
    /// - Parameters:
    ///   - startDate: Start of the date range
    ///   - endDate: End of the date range
    ///   - user: Optional user to filter by
    /// - Returns: Array of chores due within the range
    /// - Throws: Error if the fetch fails
    public func fetchDueInRange(startDate: Date, endDate: Date, user: NSManagedObject? = nil) throws -> [NSManagedObject] {
        var predicateFormat = "dueDate >= %@ AND dueDate <= %@ AND deletedAt == nil"
        var arguments: [Any] = [startDate, endDate]
        
        if let user = user {
            let userId = user.value(forKey: "id") as? UUID ?? UUID()
            predicateFormat += " AND assignedToUser.id == %@"
            arguments.append(userId as CVarArg)
        }
        
        let predicate = NSPredicate(format: predicateFormat, argumentArray: arguments)
        return try fetch(with: predicate)
    }

    /// Count chores by status for a user
    /// - Parameters:
    ///   - status: The status to count
    ///   - user: The user to count for
    /// - Returns: Number of chores with the specified status
    /// - Throws: Error if the count fails
    public func countByStatus(_ status: String, user: NSManagedObject) throws -> Int {
        let userId = user.value(forKey: "id") as? UUID ?? UUID()
        let predicate = NSPredicate(format: "status == %@ AND assignedToUser.id == %@ AND deletedAt == nil", status, userId as CVarArg)
        return try count(with: predicate)
    }
}
