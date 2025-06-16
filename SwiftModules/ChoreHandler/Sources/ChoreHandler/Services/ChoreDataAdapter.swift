import Foundation
import CoreData
import CoreServices
import ErrorHandler
import DataModels

/// Adapter that bridges ChoreModel and Core Data entities
/// This ensures consistency between ChoreHandler and DataModels
public class ChoreDataAdapter {
    
    // MARK: - Properties
    
    /// Shared instance
    public static let shared = ChoreDataAdapter()
    
    /// Chore repository from DataModels
    private let choreRepository: ChoreRepository
    
    /// User repository from DataModels
    private let userRepository: UserRepository
    
    // MARK: - Initialization
    
    private init() {
        self.choreRepository = ChoreRepository.shared
        self.userRepository = UserRepository.shared
    }
    
    // MARK: - Public Methods
    
    /// Convert ChoreModel to Core Data entity
    /// - Parameter choreModel: The ChoreModel to convert
    /// - Returns: Core Data entity or nil if conversion fails
    public func createCoreDataEntity(from choreModel: ChoreModel) throws -> NSManagedObject {
        // Get user entities for relationships
        var assignedToUser: NSManagedObject?
        var createdByUser: NSManagedObject?
        
        if let assignedToUserId = choreModel.assignedToUserId {
            assignedToUser = try userRepository.fetchByUUID(assignedToUserId)
        }
        
        if let createdByUserId = choreModel.createdByUserId {
            createdByUser = try userRepository.fetchByUUID(createdByUserId)
        }
        
        // Create the chore entity
        return try choreRepository.create(
            title: choreModel.title,
            description: choreModel.description,
            points: choreModel.points,
            dueDate: choreModel.dueDate,
            isRecurring: choreModel.isRecurring,
            recurringPattern: choreModel.recurringPattern,
            status: choreModel.status.rawValue,
            assignedToUser: assignedToUser,
            createdByUser: createdByUser,
            family: nil, // TODO: Add family support when FamilyRepository is implemented
            iconId: choreModel.iconId
        )
    }
    
    /// Convert Core Data entity to ChoreModel
    /// - Parameter entity: The Core Data entity to convert
    /// - Returns: ChoreModel representation
    public func createChoreModel(from entity: NSManagedObject) -> ChoreModel {
        let id = entity.value(forKey: "id") as? Int64 ?? 0
        let title = entity.value(forKey: "title") as? String ?? ""
        let description = entity.value(forKey: "choreDescription") as? String
        let points = entity.value(forKey: "points") as? Int16 ?? 0
        let dueDate = entity.value(forKey: "dueDate") as? Date ?? Date()
        let isRecurring = entity.value(forKey: "isRecurring") as? Bool ?? false
        let recurringPattern = entity.value(forKey: "recurringPattern") as? String
        let statusString = entity.value(forKey: "status") as? String ?? "pending"
        let iconId = entity.value(forKey: "iconId") as? String ?? "custom"
        
        // Convert status string to ChoreStatus enum
        let status = ChoreStatus(rawValue: statusString) ?? .pending
        
        // Get user IDs from relationships
        let assignedToUser = entity.value(forKey: "assignedToUser") as? NSManagedObject
        let assignedToUserId = assignedToUser?.value(forKey: "id") as? UUID
        
        let createdByUser = entity.value(forKey: "createdByUser") as? NSManagedObject
        let createdByUserId = createdByUser?.value(forKey: "id") as? UUID
        
        let family = entity.value(forKey: "family") as? NSManagedObject
        let familyId = family?.value(forKey: "id") as? Int64
        
        return ChoreModel(
            id: id,
            title: title,
            description: description,
            points: points,
            dueDate: dueDate,
            isRecurring: isRecurring,
            recurringPattern: recurringPattern,
            status: status,
            parentChoreId: nil, // TODO: Add parent chore support
            assignedToUserId: assignedToUserId,
            createdByUserId: createdByUserId,
            familyId: familyId,
            iconId: iconId
        )
    }
    
    /// Sync ChoreModel to Core Data
    /// - Parameter choreModel: The ChoreModel to sync
    /// - Returns: The synced Core Data entity
    /// - Throws: Error if sync fails
    public func syncToDataModels(_ choreModel: ChoreModel) throws -> NSManagedObject {
        // Check if entity already exists
        if let existingEntity = try choreRepository.fetch(byId: choreModel.id) {
            // Update existing entity
            try updateCoreDataEntity(existingEntity, from: choreModel)
            return existingEntity
        } else {
            // Create new entity
            return try createCoreDataEntity(from: choreModel)
        }
    }
    
    /// Update Core Data entity from ChoreModel
    /// - Parameters:
    ///   - entity: The Core Data entity to update
    ///   - choreModel: The ChoreModel with updated data
    /// - Throws: Error if update fails
    public func updateCoreDataEntity(_ entity: NSManagedObject, from choreModel: ChoreModel) throws {
        let attributes: [String: Any] = [
            "title": choreModel.title,
            "choreDescription": choreModel.description ?? "",
            "points": choreModel.points,
            "dueDate": choreModel.dueDate,
            "isRecurring": choreModel.isRecurring,
            "recurringPattern": choreModel.recurringPattern ?? "",
            "status": choreModel.status.rawValue,
            "iconId": choreModel.iconId,
            "updatedAt": Date()
        ]
        
        try choreRepository.update(entity, with: attributes)
        
        // Update relationships
        if let assignedToUserId = choreModel.assignedToUserId {
            if let assignedToUser = try userRepository.fetchByUUID(assignedToUserId) {
                entity.setValue(assignedToUser, forKey: "assignedToUser")
            }
        }
        
        if let createdByUserId = choreModel.createdByUserId {
            if let createdByUser = try userRepository.fetchByUUID(createdByUserId) {
                entity.setValue(createdByUser, forKey: "createdByUser")
            }
        }
        
        // Save the context
        var saveError: Error?
        choreRepository.performOnMainContext { context in
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
            Logger.error("Failed to save chore updates: \(saveError.localizedDescription)")
            throw DataModelError.updateFailed(saveError.localizedDescription)
        }
    }
    
    /// Fetch ChoreModels from Core Data
    /// - Parameters:
    ///   - userId: Optional user ID to filter by
    ///   - status: Optional status to filter by
    /// - Returns: Array of ChoreModels
    /// - Throws: Error if fetch fails
    public func fetchChoreModels(userId: UUID? = nil, status: ChoreStatus? = nil) throws -> [ChoreModel] {
        var entities: [NSManagedObject] = []
        
        if let userId = userId, let user = try userRepository.fetchByUUID(userId) {
            if let status = status {
                entities = try choreRepository.fetchByStatus(status.rawValue, user: user)
            } else {
                entities = try choreRepository.fetchByAssignedUser(user)
            }
        } else if let status = status {
            entities = try choreRepository.fetchByStatus(status.rawValue)
        } else {
            entities = try choreRepository.fetchAll()
        }
        
        return entities.map { createChoreModel(from: $0) }
    }
    
    /// Get Core Data entity for a chore ID
    /// - Parameter choreId: The chore ID
    /// - Returns: Core Data entity or nil if not found
    /// - Throws: Error if fetch fails
    public func getCoreDataEntity(for choreId: Int64) throws -> NSManagedObject? {
        return try choreRepository.fetch(byId: choreId)
    }
    
    /// Delete chore from Core Data
    /// - Parameter choreId: The chore ID to delete
    /// - Throws: Error if deletion fails
    public func deleteChore(_ choreId: Int64) throws {
        guard let entity = try choreRepository.fetch(byId: choreId) else {
            throw ChoreError.choreNotFound(choreId).toAppError()
        }
        
        try choreRepository.softDelete(entity)
    }
}
