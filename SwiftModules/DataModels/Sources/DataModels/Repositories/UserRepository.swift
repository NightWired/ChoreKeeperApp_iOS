import Foundation
import CoreData
import CoreServices
import ErrorHandler

/// Repository for User entities
public class UserRepository: AbstractRepository<NSManagedObject> {

    // MARK: - Properties

    /// Shared instance of the repository
    public static let shared = UserRepository()

    /// The entity name
    public override class var entityName: String {
        return "User"
    }

    // MARK: - Public Methods

    /// Create a new user
    /// - Parameters:
    ///   - firstName: The user's first name
    ///   - lastName: The user's last name
    ///   - username: The user's username
    ///   - userType: The user's type (parent or child)
    /// - Returns: The created user
    /// - Throws: Error if the creation fails
    public func create(firstName: String, lastName: String, username: String, userType: String) throws -> NSManagedObject {
        let attributes: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "username": username,
            "userType": userType,
            "id": UUID(),
            "createdAt": Date(),
            "updatedAt": Date(),
            "primaryAccount": false
        ]

        return try create(with: attributes)
    }

    /// Update a user's name
    /// - Parameters:
    ///   - user: The user to update
    ///   - firstName: The new first name
    ///   - lastName: The new last name
    /// - Throws: Error if the update fails
    public func updateName(user: NSManagedObject, firstName: String, lastName: String) throws {
        let attributes: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "updatedAt": Date()
        ]

        try update(user, with: attributes)
    }

    /// Fetch users by type
    /// - Parameter userType: The user type to fetch
    /// - Returns: The users of the specified type
    /// - Throws: Error if the fetch fails
    public func fetchByType(userType: String) throws -> [NSManagedObject] {
        let predicate = NSPredicate(format: "userType == %@ AND deletedAt == nil", userType)
        return try fetch(with: predicate)
    }

    /// Fetch users by family
    /// - Parameter family: The family to fetch users for
    /// - Returns: The users in the family
    /// - Throws: Error if the fetch fails
    public func fetchByFamily(family: NSManagedObject) throws -> [NSManagedObject] {
        guard let familyId = family.value(forKey: "id") else {
            throw DataModelError.invalidData("Family ID is nil")
        }

        let predicate = NSPredicate(format: "family.id == %@ AND deletedAt == nil", familyId as! CVarArg)
        return try fetch(with: predicate)
    }

    /// Fetch a user by username
    /// - Parameter username: The username to fetch
    /// - Returns: The user with the specified username, or nil if not found
    /// - Throws: Error if the fetch fails
    public func fetchByUsername(username: String) throws -> NSManagedObject? {
        let predicate = NSPredicate(format: "username == %@ AND deletedAt == nil", username)
        let users = try fetch(with: predicate)
        return users.first
    }

    /// Soft delete a user
    /// - Parameter user: The user to delete
    /// - Throws: Error if the deletion fails
    public func softDelete(user: NSManagedObject) throws {
        let attributes: [String: Any] = [
            "deletedAt": Date(),
            "updatedAt": Date()
        ]

        try update(user, with: attributes)
    }

    /// Set a user's primary account status
    /// - Parameters:
    ///   - user: The user to update
    ///   - isPrimary: Whether the user is a primary account
    /// - Throws: Error if the update fails
    public func setPrimaryAccount(user: NSManagedObject, isPrimary: Bool) throws {
        let attributes: [String: Any] = [
            "primaryAccount": isPrimary,
            "updatedAt": Date()
        ]

        try update(user, with: attributes)
    }

    /// Associate a user with a family
    /// - Parameters:
    ///   - user: The user to update
    ///   - family: The family to associate with
    /// - Throws: Error if the update fails
    public func associateWithFamily(user: NSManagedObject, family: NSManagedObject) throws {
        user.setValue(family, forKey: "family")
        user.setValue(Date(), forKey: "updatedAt")

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
            Logger.error("Failed to associate user with family: \(saveError.localizedDescription)")
            throw DataModelError.updateFailed(saveError.localizedDescription)
        }
    }

    /// Associate a user with an avatar
    /// - Parameters:
    ///   - user: The user to update
    ///   - avatar: The avatar to associate with
    /// - Throws: Error if the update fails
    public func associateWithAvatar(user: NSManagedObject, avatar: NSManagedObject) throws {
        guard let avatarId = avatar.value(forKey: "id") as? Int64 else {
            throw DataModelError.invalidData("Avatar ID is nil or not an Int64")
        }

        let attributes: [String: Any] = [
            "avatarId": avatarId,
            "updatedAt": Date()
        ]

        try update(user, with: attributes)

        // Add the avatar to the user's avatars relationship
        let avatars = user.mutableSetValue(forKey: "avatars")
        avatars.add(avatar)

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
            Logger.error("Failed to associate user with avatar: \(saveError.localizedDescription)")
            throw DataModelError.updateFailed(saveError.localizedDescription)
        }
    }
}
