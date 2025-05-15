import Foundation
import CoreData
import CoreServices
import ErrorHandler

/// Protocol defining the Core Data stack interface
public protocol CoreDataStackProtocol {
    /// The main managed object context
    var mainContext: NSManagedObjectContext { get }
    
    /// Create a new background context
    /// - Returns: A new background context
    func newBackgroundContext() -> NSManagedObjectContext
    
    /// Save the main context
    /// - Throws: Error if the save fails
    func saveMainContext() throws
    
    /// Save a context
    /// - Parameter context: The context to save
    /// - Throws: Error if the save fails
    func save(context: NSManagedObjectContext) throws
    
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

/// Core Data stack implementation
public class CoreDataStack: CoreDataStackProtocol {
    
    // MARK: - Properties
    
    /// The persistent container
    private let persistentContainer: NSPersistentContainer
    
    /// The main managed object context
    public var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    
    /// Initialize with a persistent container
    /// - Parameter persistentContainer: The persistent container to use
    public init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        
        // Configure the main context
        configureMainContext()
    }
    
    // MARK: - Public Methods
    
    /// Create a new background context
    /// - Returns: A new background context
    public func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        configureContext(context)
        return context
    }
    
    /// Save the main context
    /// - Throws: Error if the save fails
    public func saveMainContext() throws {
        try save(context: mainContext)
    }
    
    /// Save a context
    /// - Parameter context: The context to save
    /// - Throws: Error if the save fails
    public func save(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Logger.error("Failed to save Core Data context: \(error.localizedDescription)")
                throw DataModelError.saveFailed(error)
            }
        }
    }
    
    /// Perform a block on the main context
    /// - Parameters:
    ///   - block: The block to perform
    ///   - completion: The completion handler
    public func performOnMainContext(_ block: @escaping (NSManagedObjectContext) -> Void, completion: ((Error?) -> Void)? = nil) {
        mainContext.perform {
            block(self.mainContext)
            
            do {
                if self.mainContext.hasChanges {
                    try self.mainContext.save()
                }
                completion?(nil)
            } catch {
                Logger.error("Failed to save main context: \(error.localizedDescription)")
                completion?(error)
            }
        }
    }
    
    /// Perform a block on a background context
    /// - Parameters:
    ///   - block: The block to perform
    ///   - completion: The completion handler
    public func performOnBackgroundContext(_ block: @escaping (NSManagedObjectContext) -> Void, completion: ((Error?) -> Void)? = nil) {
        let context = newBackgroundContext()
        context.perform {
            block(context)
            
            do {
                if context.hasChanges {
                    try context.save()
                }
                completion?(nil)
            } catch {
                Logger.error("Failed to save background context: \(error.localizedDescription)")
                completion?(error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Configure the main context
    private func configureMainContext() {
        configureContext(mainContext)
    }
    
    /// Configure a context
    /// - Parameter context: The context to configure
    private func configureContext(_ context: NSManagedObjectContext) {
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
