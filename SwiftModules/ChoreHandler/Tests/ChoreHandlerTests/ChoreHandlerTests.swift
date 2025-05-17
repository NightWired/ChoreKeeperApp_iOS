import XCTest
@testable import ChoreHandler

final class ChoreHandlerTests: XCTestCase {
    // MARK: - Properties

    /// The chore service to test
    private var choreService: MockChoreService!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()

        // Initialize the chore service with mock implementations
        choreService = MockChoreService()
    }

    override func tearDown() {
        choreService = nil
        super.tearDown()
    }

    // MARK: - Tests

    /// Tests creating a one-time chore
    func testCreateOneTimeChore() throws {
        // Create a test user and family
        let userId = UUID()
        let familyId: Int64 = 1

        // Create a one-time chore
        let chore = try choreService.createOneTimeChore(
            title: "Test Chore",
            description: "Test description",
            points: 10,
            dueDate: Date().addingTimeInterval(86400), // Due tomorrow
            assignedToUserId: userId,
            createdByUserId: userId,
            familyId: familyId,
            iconId: "custom"
        )

        // Verify the chore was created correctly
        XCTAssertEqual(chore.title, "Test Chore")
        XCTAssertEqual(chore.description, "Test description")
        XCTAssertEqual(chore.points, 10)
        XCTAssertFalse(chore.isRecurring)
        XCTAssertNil(chore.recurringPattern)
        XCTAssertEqual(chore.status, .pending)
        XCTAssertEqual(chore.assignedToUserId, userId)
        XCTAssertEqual(chore.createdByUserId, userId)
        XCTAssertEqual(chore.familyId, familyId)
        XCTAssertEqual(chore.iconId, "custom")
    }

    /// Tests creating a recurring chore
    func testCreateRecurringChore() throws {
        // Create a test user and family
        let userId = UUID()
        let familyId: Int64 = 1

        // Create a weekly recurring chore
        let result = try choreService.createRecurringChore(
            title: "Test Recurring Chore",
            description: "Test description",
            points: 15,
            frequency: .weekly,
            daysOfWeek: [.monday, .wednesday, .friday],
            dayOfMonth: nil,
            useLastDayOfMonth: false,
            dueTime: "18:00",
            assignedToUserId: userId,
            createdByUserId: userId,
            familyId: familyId,
            iconId: "trash"
        )

        // Verify the parent chore was created correctly
        XCTAssertEqual(result.parent.title, "Test Recurring Chore")
        XCTAssertEqual(result.parent.description, "Test description")
        XCTAssertEqual(result.parent.points, 15)
        XCTAssertTrue(result.parent.isRecurring)
        XCTAssertNotNil(result.parent.recurringPattern)
        XCTAssertEqual(result.parent.status, .pending)
        XCTAssertEqual(result.parent.assignedToUserId, userId)
        XCTAssertEqual(result.parent.createdByUserId, userId)
        XCTAssertEqual(result.parent.familyId, familyId)
        XCTAssertEqual(result.parent.iconId, "trash")

        // Verify child chores were created
        XCTAssertFalse(result.children.isEmpty)

        // Verify the first child chore
        let firstChild = result.children.first!
        XCTAssertEqual(firstChild.title, "Test Recurring Chore")
        XCTAssertEqual(firstChild.points, 15)
        XCTAssertFalse(firstChild.isRecurring)
        XCTAssertNil(firstChild.recurringPattern)
        XCTAssertEqual(firstChild.status, .pending)
        XCTAssertEqual(firstChild.parentChoreId, result.parent.id)
        XCTAssertEqual(firstChild.assignedToUserId, userId)
        XCTAssertEqual(firstChild.createdByUserId, userId)
        XCTAssertEqual(firstChild.familyId, familyId)
        XCTAssertEqual(firstChild.iconId, "trash")
    }

    /// Tests completing a chore
    func testCompleteChore() throws {
        // Create a test user and family
        let userId = UUID()
        let familyId: Int64 = 1

        // Create a one-time chore
        let chore = try choreService.createOneTimeChore(
            title: "Test Chore",
            description: "Test description",
            points: 10,
            dueDate: Date().addingTimeInterval(86400), // Due tomorrow
            assignedToUserId: userId,
            createdByUserId: userId,
            familyId: familyId,
            iconId: "custom"
        )

        // Complete the chore without verification
        let completedChore = try choreService.completeChore(
            id: chore.id,
            completedByUserId: userId,
            requireVerification: false
        )

        // Verify the chore was completed
        XCTAssertEqual(completedChore.status, .completed)
    }

    /// Tests completing a chore with verification
    func testCompleteChoreWithVerification() throws {
        // Create a test user and family
        let userId = UUID()
        let parentUserId = UUID()
        let familyId: Int64 = 1

        // Add the parent user ID to the validator
        (choreService.choreValidator as? MockChoreValidator)?.addParentUserId(parentUserId)

        // Create a one-time chore
        let chore = try choreService.createOneTimeChore(
            title: "Test Chore",
            description: "Test description",
            points: 10,
            dueDate: Date().addingTimeInterval(86400), // Due tomorrow
            assignedToUserId: userId,
            createdByUserId: parentUserId,
            familyId: familyId,
            iconId: "custom"
        )

        // Complete the chore with verification
        let pendingChore = try choreService.completeChore(
            id: chore.id,
            completedByUserId: userId,
            requireVerification: true
        )

        // Verify the chore is pending verification
        XCTAssertEqual(pendingChore.status, .pendingVerification)

        // Verify the chore
        let verifiedChore = try choreService.verifyChore(
            id: chore.id,
            verifiedByUserId: parentUserId
        )

        // Verify the chore was verified
        XCTAssertEqual(verifiedChore.status, .verified)
    }

    /// Tests rejecting a chore
    func testRejectChore() throws {
        // Create a test user and family
        let userId = UUID()
        let parentUserId = UUID()
        let familyId: Int64 = 1

        // Add the parent user ID to the validator
        (choreService.choreValidator as? MockChoreValidator)?.addParentUserId(parentUserId)

        // Create a one-time chore
        let chore = try choreService.createOneTimeChore(
            title: "Test Chore",
            description: "Test description",
            points: 10,
            dueDate: Date().addingTimeInterval(86400), // Due tomorrow
            assignedToUserId: userId,
            createdByUserId: parentUserId,
            familyId: familyId,
            iconId: "custom"
        )

        // Complete the chore with verification
        let pendingChore = try choreService.completeChore(
            id: chore.id,
            completedByUserId: userId,
            requireVerification: true
        )

        // Verify the chore is pending verification
        XCTAssertEqual(pendingChore.status, .pendingVerification)

        // Reject the chore
        let rejectedChore = try choreService.rejectChore(
            id: chore.id,
            rejectedByUserId: parentUserId,
            reason: "Not done properly"
        )

        // Verify the chore was rejected
        XCTAssertEqual(rejectedChore.status, .rejected)
    }

    /// Tests marking a chore as missed
    func testMarkChoreMissed() throws {
        // Create a test user and family
        let userId = UUID()
        let familyId: Int64 = 1

        // Create a one-time chore
        let chore = try choreService.createOneTimeChore(
            title: "Test Chore",
            description: "Test description",
            points: 10,
            dueDate: Date().addingTimeInterval(86400), // Due tomorrow
            assignedToUserId: userId,
            createdByUserId: userId,
            familyId: familyId,
            iconId: "custom"
        )

        // Mark the chore as missed
        let missedChore = try choreService.markChoreMissed(id: chore.id)

        // Verify the chore was marked as missed
        XCTAssertEqual(missedChore.status, .missed)
    }
}
