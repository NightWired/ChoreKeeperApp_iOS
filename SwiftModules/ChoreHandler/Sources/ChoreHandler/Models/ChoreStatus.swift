import Foundation

/// Represents the status of a chore
public enum ChoreStatus: String, Codable, CaseIterable {
    /// Chore is pending (not completed)
    case pending = "pending"
    
    /// Chore is completed
    case completed = "completed"
    
    /// Chore is completed but pending verification
    case pendingVerification = "pending_verification"
    
    /// Chore is verified by a parent
    case verified = "verified"
    
    /// Chore is rejected by a parent
    case rejected = "rejected"
    
    /// Chore is missed (not completed by due date)
    case missed = "missed"
    
    /// The display name for the status
    public var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .completed:
            return "Completed"
        case .pendingVerification:
            return "Pending Verification"
        case .verified:
            return "Verified"
        case .rejected:
            return "Rejected"
        case .missed:
            return "Missed"
        }
    }
    
    /// The localization key for the status
    public var localizationKey: String {
        switch self {
        case .pending:
            return "chores.status.pending"
        case .completed:
            return "chores.status.completed"
        case .pendingVerification:
            return "chores.status.pendingVerification"
        case .verified:
            return "chores.status.verified"
        case .rejected:
            return "chores.status.rejected"
        case .missed:
            return "chores.status.missed"
        }
    }
    
    /// Whether the chore is considered completed for point allocation
    public var isCompleted: Bool {
        switch self {
        case .completed, .verified:
            return true
        case .pending, .pendingVerification, .rejected, .missed:
            return false
        }
    }
    
    /// Whether the chore is considered missed for point deduction
    public var isMissed: Bool {
        return self == .missed
    }
    
    /// Whether the chore requires verification
    public var requiresVerification: Bool {
        return self == .pendingVerification
    }
    
    /// Whether the chore can be completed
    public var canBeCompleted: Bool {
        return self == .pending || self == .rejected
    }
    
    /// Whether the chore can be verified
    public var canBeVerified: Bool {
        return self == .pendingVerification
    }
    
    /// Whether the chore can be rejected
    public var canBeRejected: Bool {
        return self == .pendingVerification
    }
}
