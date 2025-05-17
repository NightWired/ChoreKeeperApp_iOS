import Foundation

/// Represents a chore in the application
public struct ChoreModel: Identifiable, Equatable, Codable {
    /// The unique identifier for the chore
    public let id: Int64

    /// The title of the chore
    public var title: String

    /// The description of the chore
    public var description: String?

    /// The points awarded for completing the chore
    public var points: Int16

    /// The due date for the chore
    public var dueDate: Date

    /// Whether the chore is recurring
    public var isRecurring: Bool

    /// The recurring pattern for the chore
    public var recurringPattern: String?

    /// The status of the chore
    public var status: ChoreStatus

    /// The ID of the parent chore (for recurring chores)
    public var parentChoreId: Int64?

    /// The ID of the user assigned to the chore
    public var assignedToUserId: UUID?

    /// The ID of the user who created the chore
    public var createdByUserId: UUID?

    /// The ID of the family the chore belongs to
    public var familyId: Int64?

    /// The icon for the chore
    public var iconId: String

    /// The date the chore was created
    public var createdAt: Date

    /// The date the chore was last updated
    public var updatedAt: Date

    /// The date the chore was deleted, if applicable
    public var deletedAt: Date?

    /// Creates a new chore model
    /// - Parameters:
    ///   - id: The unique identifier for the chore
    ///   - title: The title of the chore
    ///   - description: The description of the chore
    ///   - points: The points awarded for completing the chore
    ///   - dueDate: The due date for the chore
    ///   - isRecurring: Whether the chore is recurring
    ///   - recurringPattern: The recurring pattern for the chore
    ///   - status: The status of the chore
    ///   - parentChoreId: The ID of the parent chore (for recurring chores)
    ///   - assignedToUserId: The ID of the user assigned to the chore
    ///   - createdByUserId: The ID of the user who created the chore
    ///   - familyId: The ID of the family the chore belongs to
    ///   - iconId: The icon for the chore
    ///   - createdAt: The date the chore was created
    ///   - updatedAt: The date the chore was last updated
    ///   - deletedAt: The date the chore was deleted, if applicable
    public init(
        id: Int64,
        title: String,
        description: String? = nil,
        points: Int16,
        dueDate: Date,
        isRecurring: Bool = false,
        recurringPattern: String? = nil,
        status: ChoreStatus = .pending,
        parentChoreId: Int64? = nil,
        assignedToUserId: UUID? = nil,
        createdByUserId: UUID? = nil,
        familyId: Int64? = nil,
        iconId: String = "custom",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.points = points
        self.dueDate = dueDate
        self.isRecurring = isRecurring
        self.recurringPattern = recurringPattern
        self.status = status
        self.parentChoreId = parentChoreId
        self.assignedToUserId = assignedToUserId
        self.createdByUserId = createdByUserId
        self.familyId = familyId
        self.iconId = iconId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    /// The frequency of the chore
    public var frequency: ChoreFrequency {
        return ChoreFrequency.from(pattern: recurringPattern)
    }

    /// The recurring pattern object for the chore
    public var pattern: RecurringPattern? {
        guard let recurringPattern = recurringPattern else {
            return nil
        }

        return RecurringPattern.fromString(recurringPattern)
    }

    /// The icon for the chore
    public var icon: ChoreIcon {
        return ChoreIcons.find(byId: iconId) ?? ChoreIcons.find(byId: "custom")!
    }

    /// Whether the chore is overdue
    public var isOverdue: Bool {
        return dueDate < Date() && status == .pending
    }

    /// Whether the chore is completed
    public var isCompleted: Bool {
        return status.isCompleted
    }

    /// Whether the chore is missed
    public var isMissed: Bool {
        return status.isMissed
    }

    /// Whether the chore requires verification
    public var requiresVerification: Bool {
        return status.requiresVerification
    }

    /// Whether the chore can be completed
    public var canBeCompleted: Bool {
        return status.canBeCompleted
    }

    /// Whether the chore can be verified
    public var canBeVerified: Bool {
        return status.canBeVerified
    }

    /// Whether the chore can be rejected
    public var canBeRejected: Bool {
        return status.canBeRejected
    }

    /// Creates a copy of the chore with updated properties
    /// - Parameter updates: A closure that updates the properties of the chore
    /// - Returns: A new chore with the updated properties
    public func copy(with updates: (inout ChoreModel) -> Void) -> ChoreModel {
        var copy = self
        updates(&copy)
        return copy
    }
}
