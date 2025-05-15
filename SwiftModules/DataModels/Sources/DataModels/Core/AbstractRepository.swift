import Foundation
import CoreData
import CoreServices
import ErrorHandler

/// Repository manager to hold Core Data stacks for repositories
public class RepositoryManager {
    /// Shared instance
    public static let shared = RepositoryManager()

    /// Core Data stack
    private var coreDataStack: CoreDataStack?

    /// Private initializer
    private init() {}

    /// Set the Core Data stack
    /// - Parameter coreDataStack: The Core Data stack to use
    public func setCoreDataStack(_ coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    /// Get the Core Data stack
    /// - Returns: The Core Data stack
    public func getCoreDataStack() -> CoreDataStack? {
        return coreDataStack
    }

    /// Reset the Core Data stack
    public func reset() {
        coreDataStack = nil
    }
}

/// Abstract base class for repositories
open class AbstractRepository<Entity: NSManagedObject>: Repository {

    // MARK: - Properties

    /// The entity name
    public class var entityName: String {
        return Entity.entity().name!
    }

    /// The Core Data stack
    private var coreDataStack: CoreDataStack? {
        return RepositoryManager.shared.getCoreDataStack()
    }

    // MARK: - Initialization

    /// Initialize the repository with a Core Data stack
    /// - Parameter coreDataStack: The Core Data stack to use
    public static func initialize(with coreDataStack: CoreDataStack) {
        RepositoryManager.shared.setCoreDataStack(coreDataStack)
    }

    /// Reset the repository
    public static func reset() {
        RepositoryManager.shared.reset()
    }

    /// Initialize a new repository
    public init() {}

    // MARK: - Public Methods

    /// Fetch all entities
    /// - Returns: All entities
    /// - Throws: Error if the fetch fails
    public func fetchAll() throws -> [Entity] {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        let request = NSFetchRequest<Entity>(entityName: Self.entityName)

        do {
            return try coreDataStack.mainContext.fetch(request)
        } catch {
            Logger.error("Failed to fetch all \(Self.entityName): \(error.localizedDescription)")
            throw DataModelError.fetchFailed(error)
        }
    }

    /// Fetch an entity by ID
    /// - Parameter id: The ID to fetch
    /// - Returns: The entity, or nil if not found
    /// - Throws: Error if the fetch fails
    public func fetch(byId id: Any) throws -> Entity? {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        let request = NSFetchRequest<Entity>(entityName: Self.entityName)
        request.predicate = NSPredicate(format: "id == %@", id as! CVarArg)
        request.fetchLimit = 1

        do {
            let results = try coreDataStack.mainContext.fetch(request)
            return results.first
        } catch {
            Logger.error("Failed to fetch \(Self.entityName) with ID \(id): \(error.localizedDescription)")
            throw DataModelError.fetchFailed(error)
        }
    }

    /// Fetch entities with a predicate
    /// - Parameter predicate: The predicate to use
    /// - Returns: The entities matching the predicate
    /// - Throws: Error if the fetch fails
    public func fetch(with predicate: NSPredicate) throws -> [Entity] {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        let request = NSFetchRequest<Entity>(entityName: Self.entityName)
        request.predicate = predicate

        do {
            return try coreDataStack.mainContext.fetch(request)
        } catch {
            Logger.error("Failed to fetch \(Self.entityName) with predicate: \(error.localizedDescription)")
            throw DataModelError.fetchFailed(error)
        }
    }

    /// Fetch entities with a query
    /// - Parameter query: The query to use
    /// - Returns: The entities matching the query
    /// - Throws: Error if the fetch fails
    public func fetch(with query: QueryBuilder<Entity>) throws -> [Entity] {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        let request = query.buildFetchRequest()

        do {
            return try coreDataStack.mainContext.fetch(request)
        } catch {
            Logger.error("Failed to fetch \(Self.entityName) with query: \(error.localizedDescription)")
            throw DataModelError.fetchFailed(error)
        }
    }

    /// Create a new entity
    /// - Parameter attributes: The attributes to set
    /// - Returns: The created entity
    /// - Throws: Error if the creation fails
    public func create(with attributes: [String: Any]) throws -> Entity {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        let entity = Entity(context: coreDataStack.mainContext)

        do {
            try update(entity, with: attributes)
            try coreDataStack.saveMainContext()
            return entity
        } catch {
            Logger.error("Failed to create \(Self.entityName): \(error.localizedDescription)")
            throw DataModelError.createFailed(error.localizedDescription)
        }
    }

    /// Update an entity
    /// - Parameters:
    ///   - entity: The entity to update
    ///   - attributes: The attributes to update
    /// - Throws: Error if the update fails
    public func update(_ entity: Entity, with attributes: [String: Any]) throws {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        for (key, value) in attributes {
            entity.setValue(value, forKey: key)
        }

        do {
            try coreDataStack.saveMainContext()
        } catch {
            Logger.error("Failed to update \(Self.entityName): \(error.localizedDescription)")
            throw DataModelError.updateFailed(error.localizedDescription)
        }
    }

    /// Delete an entity
    /// - Parameter entity: The entity to delete
    /// - Throws: Error if the deletion fails
    public func delete(_ entity: Entity) throws {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        coreDataStack.mainContext.delete(entity)

        do {
            try coreDataStack.saveMainContext()
        } catch {
            Logger.error("Failed to delete \(Self.entityName): \(error.localizedDescription)")
            throw DataModelError.deleteFailed(error.localizedDescription)
        }
    }

    /// Delete entities with a predicate
    /// - Parameter predicate: The predicate to use
    /// - Throws: Error if the deletion fails
    public func delete(with predicate: NSPredicate) throws {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        request.predicate = predicate

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try coreDataStack.mainContext.execute(deleteRequest)
            try coreDataStack.saveMainContext()
        } catch {
            Logger.error("Failed to delete \(Self.entityName) with predicate: \(error.localizedDescription)")
            throw DataModelError.deleteFailed(error.localizedDescription)
        }
    }

    /// Count entities
    /// - Returns: The number of entities
    /// - Throws: Error if the count fails
    public func count() throws -> Int {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        let request = NSFetchRequest<Entity>(entityName: Self.entityName)

        do {
            return try coreDataStack.mainContext.count(for: request)
        } catch {
            Logger.error("Failed to count \(Self.entityName): \(error.localizedDescription)")
            throw DataModelError.fetchFailed(error)
        }
    }

    /// Count entities with a predicate
    /// - Parameter predicate: The predicate to use
    /// - Returns: The number of entities matching the predicate
    /// - Throws: Error if the count fails
    public func count(with predicate: NSPredicate) throws -> Int {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        let request = NSFetchRequest<Entity>(entityName: Self.entityName)
        request.predicate = predicate

        do {
            return try coreDataStack.mainContext.count(for: request)
        } catch {
            Logger.error("Failed to count \(Self.entityName) with predicate: \(error.localizedDescription)")
            throw DataModelError.fetchFailed(error)
        }
    }

    /// Check if an entity exists
    /// - Parameter id: The ID to check
    /// - Returns: True if the entity exists, false otherwise
    /// - Throws: Error if the check fails
    public func exists(id: Any) throws -> Bool {
        guard let coreDataStack = coreDataStack else {
            throw DataModelError.coreDataStackNotInitialized
        }

        let request = NSFetchRequest<Entity>(entityName: Self.entityName)
        request.predicate = NSPredicate(format: "id == %@", id as! CVarArg)
        request.fetchLimit = 1

        do {
            let count = try coreDataStack.mainContext.count(for: request)
            return count > 0
        } catch {
            Logger.error("Failed to check if \(Self.entityName) exists with ID \(id): \(error.localizedDescription)")
            throw DataModelError.fetchFailed(error)
        }
    }

    /// Perform a block on the main context
    /// - Parameters:
    ///   - block: The block to perform
    ///   - completion: The completion handler
    public func performOnMainContext(_ block: @escaping (NSManagedObjectContext) -> Void, completion: ((Error?) -> Void)? = nil) {
        guard let coreDataStack = coreDataStack else {
            completion?(DataModelError.coreDataStackNotInitialized)
            return
        }

        coreDataStack.performOnMainContext(block, completion: completion)
    }

    /// Perform a block on a background context
    /// - Parameters:
    ///   - block: The block to perform
    ///   - completion: The completion handler
    public func performOnBackgroundContext(_ block: @escaping (NSManagedObjectContext) -> Void, completion: ((Error?) -> Void)? = nil) {
        guard let coreDataStack = coreDataStack else {
            completion?(DataModelError.coreDataStackNotInitialized)
            return
        }

        coreDataStack.performOnBackgroundContext(block, completion: completion)
    }
}
