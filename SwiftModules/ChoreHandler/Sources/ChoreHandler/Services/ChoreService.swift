import Foundation
import CoreServices
import ErrorHandler
import LocalizationHandler
import DataModels

/// Implementation of the ChoreServiceProtocol
public class ChoreService: ChoreServiceProtocol {
    // MARK: - Properties

    /// The chore repository
    private let choreRepository: ChoreRepositoryProtocol

    /// The chore generator
    private let choreGenerator: ChoreGeneratorProtocol

    /// The chore validator
    private let choreValidator: ChoreValidatorProtocol

    /// The chore scheduler
    private let choreScheduler: ChoreSchedulerProtocol

    /// The point allocation service
    private let pointAllocationService: PointAllocationServiceProtocol

    // MARK: - Initialization

    /// Creates a new chore service
    /// - Parameters:
    ///   - choreRepository: The chore repository to use
    ///   - choreGenerator: The chore generator to use
    ///   - choreValidator: The chore validator to use
    ///   - choreScheduler: The chore scheduler to use
    ///   - pointAllocationService: The point allocation service to use
    public init(
        choreRepository: ChoreRepositoryProtocol = MockChoreRepository(),
        choreGenerator: ChoreGeneratorProtocol = ChoreGenerator(),
        choreValidator: ChoreValidatorProtocol = ChoreValidator(),
        choreScheduler: ChoreSchedulerProtocol = ChoreScheduler(),
        pointAllocationService: PointAllocationServiceProtocol = PointAllocationService()
    ) {
        self.choreRepository = choreRepository
        self.choreGenerator = choreGenerator
        self.choreValidator = choreValidator
        self.choreScheduler = choreScheduler
        self.pointAllocationService = pointAllocationService
    }

    // MARK: - ChoreServiceProtocol Implementation

    /// Creates a new chore
    /// - Parameters:
    ///   - title: The title of the chore
    ///   - description: The description of the chore
    ///   - points: The points awarded for completing the chore
    ///   - dueDate: The due date for the chore
    ///   - isRecurring: Whether the chore is recurring
    ///   - recurringPattern: The recurring pattern for the chore
    ///   - assignedToUserId: The ID of the user assigned to the chore
    ///   - createdByUserId: The ID of the user who created the chore
    ///   - familyId: The ID of the family the chore belongs to
    ///   - iconId: The icon for the chore
    /// - Returns: The created chore
    /// - Throws: An error if the chore could not be created
    public func createChore(
        title: String,
        description: String?,
        points: Int16,
        dueDate: Date,
        isRecurring: Bool,
        recurringPattern: String?,
        assignedToUserId: UUID?,
        createdByUserId: UUID?,
        familyId: Int64?,
        iconId: String = "custom"
    ) throws -> ChoreModel {
        // Validate inputs
        try validateChoreInputs(
            title: title,
            points: points,
            dueDate: dueDate,
            isRecurring: isRecurring,
            recurringPattern: recurringPattern
        )

        // Create the chore in the repository
        let choreId = try choreRepository.createChore(
            title: title,
            description: description,
            points: points,
            dueDate: dueDate,
            isRecurring: isRecurring,
            recurringPattern: recurringPattern,
            status: .pending,
            parentChoreId: nil,
            assignedToUserId: assignedToUserId,
            createdByUserId: createdByUserId,
            familyId: familyId,
            iconId: iconId
        )

        // Get the created chore
        guard let chore = try choreRepository.getChore(id: choreId) else {
            throw ChoreError.createFailed("Failed to retrieve created chore").toAppError()
        }

        // Log the creation
        Logger.info("Created chore: \(title)", context: ["choreId": choreId])

        return chore
    }

    /// Creates a one-time chore
    /// - Parameters:
    ///   - title: The title of the chore
    ///   - description: The description of the chore
    ///   - points: The points awarded for completing the chore
    ///   - dueDate: The due date for the chore
    ///   - assignedToUserId: The ID of the user assigned to the chore
    ///   - createdByUserId: The ID of the user who created the chore
    ///   - familyId: The ID of the family the chore belongs to
    ///   - iconId: The icon for the chore
    /// - Returns: The created chore
    /// - Throws: An error if the chore could not be created
    public func createOneTimeChore(
        title: String,
        description: String?,
        points: Int16,
        dueDate: Date,
        assignedToUserId: UUID?,
        createdByUserId: UUID?,
        familyId: Int64?,
        iconId: String = "custom"
    ) throws -> ChoreModel {
        return try createChore(
            title: title,
            description: description,
            points: points,
            dueDate: dueDate,
            isRecurring: false,
            recurringPattern: nil,
            assignedToUserId: assignedToUserId,
            createdByUserId: createdByUserId,
            familyId: familyId,
            iconId: iconId
        )
    }

    /// Creates a recurring chore
    /// - Parameters:
    ///   - title: The title of the chore
    ///   - description: The description of the chore
    ///   - points: The points awarded for completing the chore
    ///   - frequency: The frequency of the recurring chore
    ///   - daysOfWeek: The days of the week for weekly recurring chores
    ///   - dayOfMonth: The day of the month for monthly recurring chores
    ///   - useLastDayOfMonth: Whether to use the last day of the month for monthly recurring chores
    ///   - dueTime: The time of day for the chore to be due (HH:MM format)
    ///   - assignedToUserId: The ID of the user assigned to the chore
    ///   - createdByUserId: The ID of the user who created the chore
    ///   - familyId: The ID of the family the chore belongs to
    ///   - iconId: The icon for the chore
    /// - Returns: The created parent chore and its child instances
    /// - Throws: An error if the chore could not be created
    public func createRecurringChore(
        title: String,
        description: String?,
        points: Int16,
        frequency: ChoreFrequency,
        daysOfWeek: [DayOfWeek]?,
        dayOfMonth: Int?,
        useLastDayOfMonth: Bool = false,
        dueTime: String = "22:00",
        assignedToUserId: UUID?,
        createdByUserId: UUID?,
        familyId: Int64?,
        iconId: String = "custom"
    ) throws -> (parent: ChoreModel, children: [ChoreModel]) {
        // Create the recurring pattern
        let pattern: RecurringPattern

        switch frequency {
        case .daily:
            pattern = RecurringPattern.daily(dueTime: dueTime)

        case .weekly:
            guard let daysOfWeek = daysOfWeek, !daysOfWeek.isEmpty else {
                throw ChoreError.invalidRecurringPattern("Weekly recurring chores must specify at least one day of the week").toAppError()
            }

            pattern = RecurringPattern.weekly(daysOfWeek: daysOfWeek, dueTime: dueTime)

        case .monthly:
            if useLastDayOfMonth {
                pattern = RecurringPattern.lastDayOfMonth(dueTime: dueTime)
            } else if let dayOfMonth = dayOfMonth {
                pattern = RecurringPattern.monthly(dayOfMonth: dayOfMonth, dueTime: dueTime)
            } else {
                throw ChoreError.invalidRecurringPattern("Monthly recurring chores must specify a day of the month or use the last day of the month").toAppError()
            }

        case .oneTime:
            throw ChoreError.invalidRecurringPattern("Cannot create a recurring chore with a one-time frequency").toAppError()
        }

        // Create the parent chore
        let patternString = pattern.toString()
        let parentId = Int64(Date().timeIntervalSince1970)

        let parentChore = ChoreModel(
            id: parentId,
            title: title,
            description: description,
            points: points,
            dueDate: Date(), // The parent chore doesn't have a meaningful due date
            isRecurring: true,
            recurringPattern: patternString,
            status: .pending,
            parentChoreId: nil,
            assignedToUserId: assignedToUserId,
            createdByUserId: createdByUserId,
            familyId: familyId,
            iconId: iconId
        )

        // Generate child chores
        let endDate = try choreScheduler.getRecurringChoreEndDate()
        let childChores = try choreGenerator.generateChoreInstances(
            parentChore: parentChore,
            startDate: Date(),
            endDate: endDate
        )

        // Log the creation
        Logger.info("Created recurring chore: \(title)", context: [
            "choreId": parentId,
            "frequency": frequency.rawValue,
            "childCount": childChores.count
        ])

        return (parent: parentChore, children: childChores)
    }

    /// Gets a chore by ID
    /// - Parameter id: The ID of the chore to get
    /// - Returns: The chore, or nil if not found
    /// - Throws: An error if the chore could not be retrieved
    public func getChore(id: Int64) throws -> ChoreModel? {
        return try choreRepository.getChore(id: id)
    }

    /// Gets all chores for a user
    /// - Parameter userId: The ID of the user
    /// - Returns: An array of chores assigned to the user
    /// - Throws: An error if the chores could not be retrieved
    public func getChoresForUser(userId: UUID) throws -> [ChoreModel] {
        return try choreRepository.getChoresForUser(userId: userId)
    }

    /// Gets all chores for a family
    /// - Parameter familyId: The ID of the family
    /// - Returns: An array of chores for the family
    /// - Throws: An error if the chores could not be retrieved
    public func getChoresForFamily(familyId: Int64) throws -> [ChoreModel] {
        return try choreRepository.getChoresForFamily(familyId: familyId)
    }

    /// Gets all chores with a specific status
    /// - Parameters:
    ///   - status: The status to filter by
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of chores with the specified status
    /// - Throws: An error if the chores could not be retrieved
    public func getChoresByStatus(
        status: ChoreStatus,
        userId: UUID?,
        familyId: Int64?
    ) throws -> [ChoreModel] {
        return try choreRepository.getChoresByStatus(
            status: status,
            userId: userId,
            familyId: familyId
        )
    }

    /// Gets all chores due on a specific date
    /// - Parameters:
    ///   - date: The date to filter by
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of chores due on the specified date
    /// - Throws: An error if the chores could not be retrieved
    public func getChoresDueOn(
        date: Date,
        userId: UUID?,
        familyId: Int64?
    ) throws -> [ChoreModel] {
        return try choreRepository.getChoresDueOn(
            date: date,
            userId: userId,
            familyId: familyId
        )
    }

    /// Gets all chores due between two dates
    /// - Parameters:
    ///   - startDate: The start date
    ///   - endDate: The end date
    ///   - userId: The ID of the user to filter by (optional)
    ///   - familyId: The ID of the family to filter by (optional)
    /// - Returns: An array of chores due between the specified dates
    /// - Throws: An error if the chores could not be retrieved
    public func getChoresDueBetween(
        startDate: Date,
        endDate: Date,
        userId: UUID?,
        familyId: Int64?
    ) throws -> [ChoreModel] {
        return try choreRepository.getChoresDueBetween(
            startDate: startDate,
            endDate: endDate,
            userId: userId,
            familyId: familyId
        )
    }

    /// Updates a chore
    /// - Parameters:
    ///   - id: The ID of the chore to update
    ///   - updates: A closure that updates the properties of the chore
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be updated
    public func updateChore(
        id: Int64,
        updates: (inout ChoreModel) -> Void
    ) throws -> ChoreModel {
        // Check if the chore exists
        guard try choreRepository.getChore(id: id) != nil else {
            throw ChoreError.choreNotFound(id).toAppError()
        }

        // Update the chore
        let success = try choreRepository.updateChore(id: id, updates: updates)

        if !success {
            throw ChoreError.updateFailed("Failed to update chore").toAppError()
        }

        // Get the updated chore
        guard let updatedChore = try choreRepository.getChore(id: id) else {
            throw ChoreError.choreNotFound(id).toAppError()
        }

        return updatedChore
    }

    /// Updates all future instances of a recurring chore
    /// - Parameters:
    ///   - parentId: The ID of the parent chore
    ///   - updates: A closure that updates the properties of the chores
    /// - Returns: The updated chores
    /// - Throws: An error if the chores could not be updated
    public func updateFutureChores(
        parentId: Int64,
        updates: (inout ChoreModel) -> Void
    ) throws -> [ChoreModel] {
        // Get the parent chore
        guard let parentChore = try choreRepository.getChore(id: parentId) else {
            throw ChoreError.choreNotFound(parentId).toAppError()
        }

        // Ensure the parent chore is a recurring chore
        if !parentChore.isRecurring {
            throw ChoreError.invalidChoreData("Chore is not a recurring chore").toAppError()
        }

        // Update future chores
        let updateCount = try choreRepository.updateFutureChores(parentId: parentId, updates: updates)

        if updateCount == 0 {
            throw ChoreError.updateFailed("No future chores to update").toAppError()
        }

        // Get the updated chores
        let updatedChores = try choreRepository.getChildChores(parentId: parentId)

        return updatedChores
    }

    /// Deletes a chore
    /// - Parameter id: The ID of the chore to delete
    /// - Throws: An error if the chore could not be deleted
    public func deleteChore(id: Int64) throws {
        // Check if the chore exists
        guard try choreRepository.getChore(id: id) != nil else {
            throw ChoreError.choreNotFound(id).toAppError()
        }

        // Delete the chore
        let success = try choreRepository.deleteChore(id: id)

        if !success {
            throw ChoreError.deleteFailed("Failed to delete chore").toAppError()
        }
    }

    /// Deletes all future instances of a recurring chore
    /// - Parameter parentId: The ID of the parent chore
    /// - Throws: An error if the chores could not be deleted
    public func deleteFutureChores(parentId: Int64) throws {
        // Get the parent chore
        guard let parentChore = try choreRepository.getChore(id: parentId) else {
            throw ChoreError.choreNotFound(parentId).toAppError()
        }

        // Ensure the parent chore is a recurring chore
        if !parentChore.isRecurring {
            throw ChoreError.invalidChoreData("Chore is not a recurring chore").toAppError()
        }

        // Delete future chores
        let deleteCount = try choreRepository.deleteFutureChores(parentId: parentId)

        if deleteCount == 0 {
            throw ChoreError.deleteFailed("No future chores to delete").toAppError()
        }
    }

    /// Marks a chore as completed
    /// - Parameters:
    ///   - id: The ID of the chore to mark as completed
    ///   - completedByUserId: The ID of the user who completed the chore
    ///   - requireVerification: Whether the chore requires verification
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be marked as completed
    public func completeChore(
        id: Int64,
        completedByUserId: UUID,
        requireVerification: Bool = true
    ) throws -> ChoreModel {
        // Get the chore
        guard let chore = try getChore(id: id) else {
            throw ChoreError.choreNotFound(id).toAppError()
        }

        // Validate that the chore can be completed
        try validateCanComplete(chore: chore, userId: completedByUserId)

        // Update the chore status
        let newStatus: ChoreStatus = requireVerification ? .pendingVerification : .completed

        let updatedChore = try updateChore(id: id) { chore in
            var mutableChore = chore
            mutableChore.status = newStatus
            chore = mutableChore
        }

        // If the chore doesn't require verification, allocate points
        if !requireVerification {
            try allocatePointsForCompletedChore(chore: updatedChore)
        }

        // Log the completion
        Logger.info("Chore completed: \(chore.title)", context: [
            "choreId": id,
            "userId": completedByUserId,
            "requireVerification": requireVerification
        ])

        return updatedChore
    }

    /// Verifies a completed chore
    /// - Parameters:
    ///   - id: The ID of the chore to verify
    ///   - verifiedByUserId: The ID of the user who verified the chore
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be verified
    public func verifyChore(
        id: Int64,
        verifiedByUserId: UUID
    ) throws -> ChoreModel {
        // Get the chore
        guard let chore = try getChore(id: id) else {
            throw ChoreError.choreNotFound(id).toAppError()
        }

        // Validate that the chore can be verified
        try validateCanVerify(chore: chore, userId: verifiedByUserId)

        // Update the chore status
        let updatedChore = try updateChore(id: id) { chore in
            var mutableChore = chore
            mutableChore.status = .verified
            chore = mutableChore
        }

        // Allocate points
        try allocatePointsForCompletedChore(chore: updatedChore)

        // Log the verification
        Logger.info("Chore verified: \(chore.title)", context: [
            "choreId": id,
            "userId": verifiedByUserId
        ])

        return updatedChore
    }

    /// Rejects a completed chore
    /// - Parameters:
    ///   - id: The ID of the chore to reject
    ///   - rejectedByUserId: The ID of the user who rejected the chore
    ///   - reason: The reason for rejection
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be rejected
    public func rejectChore(
        id: Int64,
        rejectedByUserId: UUID,
        reason: String?
    ) throws -> ChoreModel {
        // Get the chore
        guard let chore = try getChore(id: id) else {
            throw ChoreError.choreNotFound(id).toAppError()
        }

        // Validate that the chore can be rejected
        try validateCanReject(chore: chore, userId: rejectedByUserId)

        // Update the chore status
        let updatedChore = try updateChore(id: id) { chore in
            var mutableChore = chore
            mutableChore.status = .rejected
            chore = mutableChore
        }

        // Log the rejection
        Logger.info("Chore rejected: \(chore.title)", context: [
            "choreId": id,
            "userId": rejectedByUserId,
            "reason": reason ?? "No reason provided"
        ])

        return updatedChore
    }

    /// Marks a chore as missed
    /// - Parameter id: The ID of the chore to mark as missed
    /// - Returns: The updated chore
    /// - Throws: An error if the chore could not be marked as missed
    public func markChoreMissed(id: Int64) throws -> ChoreModel {
        // Get the chore
        guard let chore = try getChore(id: id) else {
            throw ChoreError.choreNotFound(id).toAppError()
        }

        // Validate that the chore can be marked as missed
        if chore.status != .pending {
            throw ChoreError.invalidStatus("Chore must be pending to be marked as missed").toAppError()
        }

        // Update the chore status
        let updatedChore = try updateChore(id: id) { chore in
            var mutableChore = chore
            mutableChore.status = .missed
            chore = mutableChore
        }

        // Deduct points
        try deductPointsForMissedChore(chore: updatedChore)

        // Log the missed chore
        Logger.info("Chore missed: \(chore.title)", context: [
            "choreId": id
        ])

        return updatedChore
    }

    /// Checks for overdue chores and marks them as missed
    /// - Returns: The number of chores marked as missed
    /// - Throws: An error if the chores could not be checked
    public func checkOverdueChores() throws -> Int {
        // Get overdue chores
        let overdueChores = try choreScheduler.getOverdueChores(userId: nil, familyId: nil)

        // Mark each chore as missed
        var missedCount = 0

        for chore in overdueChores {
            do {
                _ = try markChoreMissed(id: chore.id)
                missedCount += 1
            } catch {
                Logger.error("Failed to mark chore as missed: \(error.localizedDescription)", context: [
                    "choreId": chore.id
                ])
            }
        }

        return missedCount
    }

    /// Generates recurring chore instances for the next period
    /// - Returns: The number of chore instances generated
    /// - Throws: An error if the chores could not be generated
    public func generateRecurringChores() throws -> Int {
        // Check if it's time to generate chores for the next month
        guard try choreScheduler.shouldGenerateNextMonthChores() else {
            return 0
        }

        // Generate chores for the next month
        return try choreGenerator.generateNextMonthChores(familyId: nil)
    }

    // MARK: - Private Methods

    /// Validates chore inputs
    /// - Parameters:
    ///   - title: The title of the chore
    ///   - points: The points awarded for completing the chore
    ///   - dueDate: The due date for the chore
    ///   - isRecurring: Whether the chore is recurring
    ///   - recurringPattern: The recurring pattern for the chore
    /// - Throws: An error if the inputs are invalid
    private func validateChoreInputs(
        title: String,
        points: Int16,
        dueDate: Date,
        isRecurring: Bool,
        recurringPattern: String?
    ) throws {
        // Validate title
        _ = try choreValidator.validateTitle(title)

        // Validate points
        _ = try choreValidator.validatePoints(points)

        // Validate due date
        _ = try choreValidator.validateDueDate(dueDate)

        // Validate recurring pattern
        if isRecurring, let pattern = recurringPattern {
            guard let recurringPattern = RecurringPattern.fromString(pattern) else {
                throw ChoreError.invalidRecurringPattern("Invalid recurring pattern format").toAppError()
            }

            _ = try choreValidator.validateRecurringPattern(recurringPattern)
        }
    }

    /// Validates that a user can complete a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Throws: An error if the user cannot complete the chore
    private func validateCanComplete(chore: ChoreModel, userId: UUID) throws {
        _ = try choreValidator.validateCanComplete(chore: chore, userId: userId)
    }

    /// Validates that a user can verify a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Throws: An error if the user cannot verify the chore
    private func validateCanVerify(chore: ChoreModel, userId: UUID) throws {
        _ = try choreValidator.validateCanVerify(chore: chore, userId: userId)
    }

    /// Validates that a user can reject a chore
    /// - Parameters:
    ///   - chore: The chore to validate
    ///   - userId: The ID of the user
    /// - Throws: An error if the user cannot reject the chore
    private func validateCanReject(chore: ChoreModel, userId: UUID) throws {
        _ = try choreValidator.validateCanReject(chore: chore, userId: userId)
    }

    /// Allocates points for a completed chore
    /// - Parameter chore: The completed chore
    /// - Throws: An error if the points could not be allocated
    private func allocatePointsForCompletedChore(chore: ChoreModel) throws {
        guard let userId = chore.assignedToUserId else {
            return
        }

        do {
            _ = try pointAllocationService.allocatePoints(
                points: chore.points,
                userId: userId,
                choreId: chore.id,
                completionDate: Date()
            )
        } catch {
            throw ChoreError.pointAllocationFailed("Failed to allocate points for completed chore: \(error.localizedDescription)").toAppError()
        }
    }

    /// Deducts points for a missed chore
    /// - Parameter chore: The missed chore
    /// - Throws: An error if the points could not be deducted
    private func deductPointsForMissedChore(chore: ChoreModel) throws {
        guard let userId = chore.assignedToUserId else {
            return
        }

        do {
            _ = try pointAllocationService.deductPoints(
                points: chore.points,
                userId: userId,
                choreId: chore.id,
                missedDate: Date()
            )
        } catch {
            throw ChoreError.pointDeductionFailed("Failed to deduct points for missed chore: \(error.localizedDescription)").toAppError()
        }
    }
}
