import Foundation
import ErrorHandler

/// Errors that can occur in the ChoreHandler module
public enum ChoreError: Error {
    /// Failed to create a chore
    case createFailed(String)
    
    /// Failed to update a chore
    case updateFailed(String)
    
    /// Failed to delete a chore
    case deleteFailed(String)
    
    /// Chore not found
    case choreNotFound(Int64)
    
    /// Invalid chore data
    case invalidChoreData(String)
    
    /// Invalid recurring pattern
    case invalidRecurringPattern(String)
    
    /// Invalid due date
    case invalidDueDate(String)
    
    /// Invalid points
    case invalidPoints(String)
    
    /// Invalid title
    case invalidTitle(String)
    
    /// Invalid user
    case invalidUser(String)
    
    /// Invalid family
    case invalidFamily(String)
    
    /// Invalid chore status
    case invalidStatus(String)
    
    /// Permission denied
    case permissionDenied(String)
    
    /// Chore already completed
    case alreadyCompleted(Int64)
    
    /// Chore already verified
    case alreadyVerified(Int64)
    
    /// Chore already rejected
    case alreadyRejected(Int64)
    
    /// Chore already missed
    case alreadyMissed(Int64)
    
    /// Failed to allocate points
    case pointAllocationFailed(String)
    
    /// Failed to deduct points
    case pointDeductionFailed(String)
    
    /// Failed to generate recurring chores
    case recurringGenerationFailed(String)
}

/// Extension to convert ChoreError to AppError
extension ChoreError {
    /// Converts a ChoreError to an AppError
    /// - Returns: The corresponding AppError
    public func toAppError() -> AppError {
        switch self {
        case .createFailed(let message):
            return AppError(
                code: .operationFailed,
                severity: .medium,
                message: "Failed to create chore: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .updateFailed(let message):
            return AppError(
                code: .operationFailed,
                severity: .medium,
                message: "Failed to update chore: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .deleteFailed(let message):
            return AppError(
                code: .operationFailed,
                severity: .medium,
                message: "Failed to delete chore: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .choreNotFound(let id):
            return AppError(
                code: .dataNotFound,
                severity: .medium,
                message: "Chore not found with ID: \(id)",
                underlyingError: self,
                context: ["category": "choreManagement", "choreId": id]
            )
            
        case .invalidChoreData(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid chore data: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .invalidRecurringPattern(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid recurring pattern: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .invalidDueDate(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid due date: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .invalidPoints(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid points: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .invalidTitle(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid title: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .invalidUser(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid user: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .invalidFamily(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid family: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .invalidStatus(let message):
            return AppError(
                code: .invalidInput,
                severity: .medium,
                message: "Invalid status: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .permissionDenied(let message):
            return AppError(
                code: .permissionDenied,
                severity: .medium,
                message: "Permission denied: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
            
        case .alreadyCompleted(let id):
            return AppError(
                code: .invalidState,
                severity: .low,
                message: "Chore already completed with ID: \(id)",
                underlyingError: self,
                context: ["category": "choreManagement", "choreId": id]
            )
            
        case .alreadyVerified(let id):
            return AppError(
                code: .invalidState,
                severity: .low,
                message: "Chore already verified with ID: \(id)",
                underlyingError: self,
                context: ["category": "choreManagement", "choreId": id]
            )
            
        case .alreadyRejected(let id):
            return AppError(
                code: .invalidState,
                severity: .low,
                message: "Chore already rejected with ID: \(id)",
                underlyingError: self,
                context: ["category": "choreManagement", "choreId": id]
            )
            
        case .alreadyMissed(let id):
            return AppError(
                code: .invalidState,
                severity: .low,
                message: "Chore already missed with ID: \(id)",
                underlyingError: self,
                context: ["category": "choreManagement", "choreId": id]
            )
            
        case .pointAllocationFailed(let message):
            return AppError(
                code: .operationFailed,
                severity: .medium,
                message: "Failed to allocate points: \(message)",
                underlyingError: self,
                context: ["category": "pointManagement"]
            )
            
        case .pointDeductionFailed(let message):
            return AppError(
                code: .operationFailed,
                severity: .medium,
                message: "Failed to deduct points: \(message)",
                underlyingError: self,
                context: ["category": "pointManagement"]
            )
            
        case .recurringGenerationFailed(let message):
            return AppError(
                code: .operationFailed,
                severity: .medium,
                message: "Failed to generate recurring chores: \(message)",
                underlyingError: self,
                context: ["category": "choreManagement"]
            )
        }
    }
}
