import Foundation
import ErrorHandler

/// Errors that can occur in the DataModels module
public enum DataModelError: Error {
    /// Failed to save the Core Data context
    case saveFailed(Error)

    /// Failed to fetch data
    case fetchFailed(Error)

    /// Failed to create an entity
    case createFailed(String)

    /// Failed to update an entity
    case updateFailed(String)

    /// Failed to delete an entity
    case deleteFailed(String)

    /// Entity not found
    case entityNotFound(String)

    /// Invalid data
    case invalidData(String)

    /// Core Data stack not initialized
    case coreDataStackNotInitialized

    /// Repository not initialized
    case repositoryNotInitialized(String)

    /// Invalid relationship
    case invalidRelationship(String)

    /// Invalid query
    case invalidQuery(String)
}

/// Extension to convert DataModelError to AppError
extension DataModelError {
    /// Convert to AppError
    /// - Returns: The AppError
    func toAppError() -> AppError {
        switch self {
        case .saveFailed(let error):
            return AppError(
                code: .dataSaveFailed,
                severity: .high,
                message: "Failed to save data: \(error.localizedDescription)",
                underlyingError: error
            )
        case .fetchFailed(let error):
            return AppError(
                code: .dataLoadFailed,
                severity: .medium,
                message: "Failed to fetch data: \(error.localizedDescription)",
                underlyingError: error
            )
        case .createFailed(let message):
            return AppError(
                code: .dataSaveFailed,
                severity: .medium,
                message: "Failed to create entity: \(message)"
            )
        case .updateFailed(let message):
            return AppError(
                code: .dataSaveFailed,
                severity: .medium,
                message: "Failed to update entity: \(message)"
            )
        case .deleteFailed(let message):
            return AppError(
                code: .dataDeleteFailed,
                severity: .medium,
                message: "Failed to delete entity: \(message)"
            )
        case .entityNotFound(let message):
            return AppError(
                code: .dataNotFound,
                severity: .low,
                message: "Entity not found: \(message)"
            )
        case .invalidData(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid data: \(message)"
            )
        case .coreDataStackNotInitialized:
            return AppError(
                code: .databaseError,
                severity: .critical,
                message: "Core Data stack not initialized"
            )
        case .repositoryNotInitialized(let repository):
            return AppError(
                code: .databaseError,
                severity: .high,
                message: "Repository not initialized: \(repository)"
            )
        case .invalidRelationship(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid relationship: \(message)"
            )
        case .invalidQuery(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid query: \(message)"
            )
        }
    }
}
