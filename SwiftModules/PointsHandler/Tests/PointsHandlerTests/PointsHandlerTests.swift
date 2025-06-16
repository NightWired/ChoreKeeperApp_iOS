import XCTest
@testable import PointsHandler
@testable import DataModels
@testable import CoreServices
@testable import ErrorHandler

final class PointsHandlerTests: XCTestCase {
    
    var pointService: PointService!
    var mockUser: MockUser!
    var mockChore: MockChore!
    
    override func setUpWithError() throws {
        // Initialize the modules
        PointsHandler.initialize()
        DataModels.initialize(with: MockCoreDataStack())
        
        pointService = PointService.shared
        mockUser = MockUser()
        mockChore = MockChore()
    }
    
    override func tearDownWithError() throws {
        PointsHandler.reset()
        DataModels.reset()
        pointService = nil
        mockUser = nil
        mockChore = nil
    }
    
    // MARK: - Point Allocation Tests
    
    func testAllocatePointsForChoreCompletion() throws {
        // Given
        let pointAmount: Int16 = 10
        
        // When
        try pointService.allocatePoints(
            amount: pointAmount,
            to: mockUser,
            for: .choreCompletion,
            chore: mockChore,
            reason: "Completed test chore"
        )
        
        // Then
        let totals = try pointService.getPointTotals(for: mockUser)
        XCTAssertEqual(totals.current, pointAmount)
        XCTAssertEqual(totals.daily, pointAmount)
        XCTAssertEqual(totals.weekly, pointAmount)
        XCTAssertEqual(totals.monthly, pointAmount)
    }
    
    func testAllocatePointsWithInvalidAmount() throws {
        // Given
        let invalidAmount: Int16 = -5
        
        // When & Then
        XCTAssertThrowsError(try pointService.allocatePoints(
            amount: invalidAmount,
            to: mockUser,
            for: .choreCompletion,
            reason: "Invalid test"
        )) { error in
            XCTAssertTrue(error is AppError)
        }
    }
    
    // MARK: - Point Deduction Tests
    
    func testDeductPointsForMissedChore() throws {
        // Given
        let initialPoints: Int16 = 20
        let deductionAmount: Int16 = 5
        
        // First allocate some points
        try pointService.allocatePoints(
            amount: initialPoints,
            to: mockUser,
            for: .choreCompletion,
            reason: "Initial points"
        )
        
        // When
        try pointService.deductPoints(
            amount: deductionAmount,
            from: mockUser,
            for: .choreMissed,
            chore: mockChore,
            reason: "Missed test chore"
        )
        
        // Then
        let totals = try pointService.getPointTotals(for: mockUser)
        XCTAssertEqual(totals.current, initialPoints - deductionAmount)
    }
    
    func testDeductPointsWithInsufficientBalance() throws {
        // Given
        let deductionAmount: Int16 = 10
        // User has 0 points initially
        
        // When & Then
        XCTAssertThrowsError(try pointService.deductPoints(
            amount: deductionAmount,
            from: mockUser,
            for: .choreMissed,
            reason: "Test deduction"
        )) { error in
            XCTAssertTrue(error is AppError)
        }
    }
    
    // MARK: - Manual Adjustment Tests
    
    func testManualPointAdjustmentPositive() throws {
        // Given
        let adjustmentAmount: Int16 = 15
        let reason = "Good behavior bonus"
        
        // When
        try pointService.adjustPoints(
            amount: adjustmentAmount,
            for: mockUser,
            reason: reason
        )
        
        // Then
        let totals = try pointService.getPointTotals(for: mockUser)
        XCTAssertEqual(totals.current, adjustmentAmount)
    }
    
    func testManualPointAdjustmentNegative() throws {
        // Given
        let initialPoints: Int16 = 20
        let adjustmentAmount: Int16 = -5
        let reason = "Behavior correction"
        
        // First allocate some points
        try pointService.allocatePoints(
            amount: initialPoints,
            to: mockUser,
            for: .choreCompletion,
            reason: "Initial points"
        )
        
        // When
        try pointService.adjustPoints(
            amount: adjustmentAmount,
            for: mockUser,
            reason: reason
        )
        
        // Then
        let totals = try pointService.getPointTotals(for: mockUser)
        XCTAssertEqual(totals.current, initialPoints + adjustmentAmount)
    }
    
    func testManualAdjustmentWithZeroAmount() throws {
        // Given
        let zeroAmount: Int16 = 0
        
        // When & Then
        XCTAssertThrowsError(try pointService.adjustPoints(
            amount: zeroAmount,
            for: mockUser,
            reason: "Zero adjustment"
        )) { error in
            XCTAssertTrue(error is AppError)
        }
    }
    
    // MARK: - Point Query Tests
    
    func testGetPointTotals() throws {
        // Given
        let pointAmount: Int16 = 25
        
        try pointService.allocatePoints(
            amount: pointAmount,
            to: mockUser,
            for: .choreCompletion,
            reason: "Test allocation"
        )
        
        // When
        let totals = try pointService.getPointTotals(for: mockUser)
        
        // Then
        XCTAssertEqual(totals.current, pointAmount)
        XCTAssertEqual(totals.daily, pointAmount)
        XCTAssertEqual(totals.weekly, pointAmount)
        XCTAssertEqual(totals.monthly, pointAmount)
    }
    
    func testHasSufficientPoints() throws {
        // Given
        let pointAmount: Int16 = 30
        let checkAmount: Int16 = 20
        
        try pointService.allocatePoints(
            amount: pointAmount,
            to: mockUser,
            for: .choreCompletion,
            reason: "Test allocation"
        )
        
        // When
        let hasSufficient = try pointService.hasSufficientPoints(mockUser, amount: checkAmount)
        let hasInsufficient = try pointService.hasSufficientPoints(mockUser, amount: 40)
        
        // Then
        XCTAssertTrue(hasSufficient)
        XCTAssertFalse(hasInsufficient)
    }
    
    // MARK: - Transaction History Tests
    
    func testGetTransactionHistory() throws {
        // Given
        try pointService.allocatePoints(
            amount: 10,
            to: mockUser,
            for: .choreCompletion,
            reason: "First transaction"
        )
        
        try pointService.allocatePoints(
            amount: 5,
            to: mockUser,
            for: .bonus,
            reason: "Second transaction"
        )
        
        // When
        let history = try pointService.getTransactionHistory(for: mockUser, limit: 10)
        
        // Then
        XCTAssertEqual(history.count, 2)
    }
    
    func testGetStatistics() throws {
        // Given
        try pointService.allocatePoints(
            amount: 15,
            to: mockUser,
            for: .choreCompletion,
            reason: "Earned points"
        )
        
        try pointService.deductPoints(
            amount: 5,
            from: mockUser,
            for: .rewardRedemption,
            reason: "Spent points"
        )
        
        // When
        let statistics = try pointService.getStatistics(for: mockUser)
        
        // Then
        XCTAssertEqual(statistics.totalEarned, 15)
        XCTAssertEqual(statistics.totalSpent, 5)
        XCTAssertEqual(statistics.netPoints, 10)
        XCTAssertEqual(statistics.transactionCount, 2)
    }
    
    // MARK: - Configuration Tests
    
    func testPointsHandlerConfiguration() throws {
        // Given
        let config = PointsConfiguration(
            allowNegativeBalances: true,
            defaultChorePoints: 15
        )
        
        // When
        PointsHandler.shared.updateConfiguration(config)
        let retrievedConfig = PointsHandler.shared.getConfiguration()
        
        // Then
        XCTAssertTrue(retrievedConfig.allowNegativeBalances)
        XCTAssertEqual(retrievedConfig.defaultChorePoints, 15)
    }
}
