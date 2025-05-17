//
//  TestUsers.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-16.
//

import Foundation
import CoreData

// Test users for development purposes
struct TestUsers {
    // Create test users for use in the app
    static func createTestParentUser(context: NSManagedObjectContext) -> NSManagedObject {
        let parentUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        parentUser.setValue(UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"), forKey: "id")
        parentUser.setValue("testparent", forKey: "username")
        parentUser.setValue("Test", forKey: "firstName")
        parentUser.setValue("Parent", forKey: "lastName")
        parentUser.setValue("parent", forKey: "userType")
        parentUser.setValue(Int64(1), forKey: "avatarId")
        parentUser.setValue(Date(), forKey: "createdAt")
        parentUser.setValue(Date(), forKey: "updatedAt")
        parentUser.setValue(true, forKey: "primaryAccount")
        return parentUser
    }

    static func createTestChildUser(context: NSManagedObjectContext) -> NSManagedObject {
        let childUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        childUser.setValue(UUID(uuidString: "C1H2I3L4-D5U6-7890-ABCD-EF1234567890"), forKey: "id")
        childUser.setValue("testchild", forKey: "username")
        childUser.setValue("Test", forKey: "firstName")
        childUser.setValue("Child", forKey: "lastName")
        childUser.setValue("child", forKey: "userType")
        childUser.setValue(Int64(2), forKey: "avatarId")
        childUser.setValue(Date(), forKey: "createdAt")
        childUser.setValue(Date(), forKey: "updatedAt")
        childUser.setValue(false, forKey: "primaryAccount")
        return childUser
    }

    static func createTestFamily(context: NSManagedObjectContext, parentUser: NSManagedObject, childUser: NSManagedObject) -> NSManagedObject {
        let family = NSEntityDescription.insertNewObject(forEntityName: "Family", into: context)
        family.setValue(Int64(1), forKey: "id")
        family.setValue("Test Family", forKey: "name")
        family.setValue(Date(), forKey: "createdAt")
        family.setValue(Date(), forKey: "updatedAt")
        family.setValue("TESTCODE", forKey: "syncCode")

        // Set up relationships
        family.setValue(NSSet(array: [parentUser, childUser]), forKey: "members")
        parentUser.setValue(family, forKey: "family")
        childUser.setValue(family, forKey: "family")

        return family
    }

    // Create all test data
    static func createTestData(context: NSManagedObjectContext) {
        let parentUser = createTestParentUser(context: context)
        let childUser = createTestChildUser(context: context)
        let _ = createTestFamily(context: context, parentUser: parentUser, childUser: childUser)

        do {
            try context.save()
        } catch {
            print("Error saving test data: \(error)")
        }
    }
}

// User role enum for use in the app
enum TestUserRole: String {
    case parent
    case child
}
