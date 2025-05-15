import Foundation
import CoreData

/// Protocol defining the base repository interface
public protocol Repository {
    /// The entity type
    associatedtype Entity: NSManagedObject

    /// The entity name
    static var entityName: String { get }

    /// Initialize the repository with a Core Data stack
    /// - Parameter coreDataStack: The Core Data stack to use
    static func initialize(with coreDataStack: CoreDataStack)

    /// Reset the repository
    static func reset()

    /// Fetch all entities
    /// - Returns: All entities
    /// - Throws: Error if the fetch fails
    func fetchAll() throws -> [Entity]

    /// Fetch an entity by ID
    /// - Parameter id: The ID to fetch
    /// - Returns: The entity, or nil if not found
    /// - Throws: Error if the fetch fails
    func fetch(byId id: Any) throws -> Entity?

    /// Fetch entities with a predicate
    /// - Parameter predicate: The predicate to use
    /// - Returns: The entities matching the predicate
    /// - Throws: Error if the fetch fails
    func fetch(with predicate: NSPredicate) throws -> [Entity]

    /// Fetch entities with a query
    /// - Parameter query: The query to use
    /// - Returns: The entities matching the query
    /// - Throws: Error if the fetch fails
    func fetch(with query: QueryBuilder<Entity>) throws -> [Entity]

    /// Create a new entity
    /// - Parameter attributes: The attributes to set
    /// - Returns: The created entity
    /// - Throws: Error if the creation fails
    func create(with attributes: [String: Any]) throws -> Entity

    /// Update an entity
    /// - Parameters:
    ///   - entity: The entity to update
    ///   - attributes: The attributes to update
    /// - Throws: Error if the update fails
    func update(_ entity: Entity, with attributes: [String: Any]) throws

    /// Delete an entity
    /// - Parameter entity: The entity to delete
    /// - Throws: Error if the deletion fails
    func delete(_ entity: Entity) throws

    /// Delete entities with a predicate
    /// - Parameter predicate: The predicate to use
    /// - Throws: Error if the deletion fails
    func delete(with predicate: NSPredicate) throws

    /// Count entities
    /// - Returns: The number of entities
    /// - Throws: Error if the count fails
    func count() throws -> Int

    /// Count entities with a predicate
    /// - Parameter predicate: The predicate to use
    /// - Returns: The number of entities matching the predicate
    /// - Throws: Error if the count fails
    func count(with predicate: NSPredicate) throws -> Int

    /// Check if an entity exists
    /// - Parameter id: The ID to check
    /// - Returns: True if the entity exists, false otherwise
    /// - Throws: Error if the check fails
    func exists(id: Any) throws -> Bool

    /// Perform a block on the main context
    /// - Parameters:
    ///   - block: The block to perform
    ///   - completion: The completion handler
    func performOnMainContext(_ block: @escaping (NSManagedObjectContext) -> Void, completion: ((Error?) -> Void)?)

    /// Perform a block on a background context
    /// - Parameters:
    ///   - block: The block to perform
    ///   - completion: The completion handler
    func performOnBackgroundContext(_ block: @escaping (NSManagedObjectContext) -> Void, completion: ((Error?) -> Void)?)
}
