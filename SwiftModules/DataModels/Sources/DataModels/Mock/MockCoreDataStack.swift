import Foundation
import CoreData
import CoreServices
import ErrorHandler

/// Mock implementation of the Core Data stack for testing
public class MockCoreDataStack: CoreDataStack {

    // MARK: - Initialization

    /// Initialize a new mock Core Data stack
    public init() {
        // Create an in-memory persistent store
        let container = NSPersistentContainer(name: "ChoreKeeperTest")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load in-memory persistent store: \(error), \(error.userInfo)")
            }
        }

        super.init(persistentContainer: container)
    }

    // MARK: - Test Data

    /// Create test data in the mock Core Data stack
    /// - Throws: Error if the creation fails
    public func createTestData() throws {
        // Create a family
        let family = NSEntityDescription.insertNewObject(forEntityName: "Family", into: mainContext)
        family.setValue("Test Family", forKey: "name")
        family.setValue(Int64(1), forKey: "id")
        family.setValue(Date(), forKey: "createdAt")
        family.setValue(Date(), forKey: "updatedAt")

        // Create a parent user
        let parent = NSEntityDescription.insertNewObject(forEntityName: "User", into: mainContext)
        parent.setValue("John", forKey: "firstName")
        parent.setValue("Doe", forKey: "lastName")
        parent.setValue("johndoe", forKey: "username")
        parent.setValue("parent", forKey: "userType")
        parent.setValue(UUID(), forKey: "id")
        parent.setValue(Date(), forKey: "createdAt")
        parent.setValue(Date(), forKey: "updatedAt")
        parent.setValue(true, forKey: "primaryAccount")
        parent.setValue(family, forKey: "family")

        // Create a child user
        let child = NSEntityDescription.insertNewObject(forEntityName: "User", into: mainContext)
        child.setValue("Jane", forKey: "firstName")
        child.setValue("Doe", forKey: "lastName")
        child.setValue("janedoe", forKey: "username")
        child.setValue("child", forKey: "userType")
        child.setValue(UUID(), forKey: "id")
        child.setValue(Date(), forKey: "createdAt")
        child.setValue(Date(), forKey: "updatedAt")
        child.setValue(false, forKey: "primaryAccount")
        child.setValue(family, forKey: "family")

        // Create period settings
        let periods = ["daily", "weekly", "monthly"]
        let types = ["reward", "penalty"]

        for period in periods {
            for type in types {
                let periodSettings = NSEntityDescription.insertNewObject(forEntityName: "PeriodSettings", into: mainContext)
                periodSettings.setValue(Int64(Date().timeIntervalSince1970 * 1000), forKey: "id")
                periodSettings.setValue(period, forKey: "period")
                periodSettings.setValue(type, forKey: "type")
                periodSettings.setValue(type == "reward" ? "cumulative" : "highestTier", forKey: "applicationMode")
                periodSettings.setValue(Date(), forKey: "createdAt")
                periodSettings.setValue(Date(), forKey: "updatedAt")
                periodSettings.setValue(family, forKey: "family")
            }
        }

        try mainContext.save()
    }
}
