import Foundation
import CoreData

/// Mock user object for testing
class MockUser: NSManagedObject {
    private var mockValues: [String: Any] = [:]
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: NSEntityDescription(), insertInto: nil)
        setupMockValues()
    }
    
    convenience init() {
        self.init(entity: NSEntityDescription(), insertInto: nil)
    }
    
    private func setupMockValues() {
        mockValues = [
            "id": Int64(1),
            "firstName": "Test",
            "lastName": "User",
            "username": "testuser",
            "userType": "child",
            "createdAt": Date(),
            "updatedAt": Date()
        ]
    }
    
    override func value(forKey key: String) -> Any? {
        return mockValues[key]
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        mockValues[key] = value
    }
}

/// Mock chore object for testing
class MockChore: NSManagedObject {
    private var mockValues: [String: Any] = [:]
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: NSEntityDescription(), insertInto: nil)
        setupMockValues()
    }
    
    convenience init() {
        self.init(entity: NSEntityDescription(), insertInto: nil)
    }
    
    private func setupMockValues() {
        mockValues = [
            "id": Int64(1),
            "title": "Test Chore",
            "choreDescription": "A test chore for unit testing",
            "points": Int16(10),
            "status": "pending",
            "createdAt": Date(),
            "updatedAt": Date()
        ]
    }
    
    override func value(forKey key: String) -> Any? {
        return mockValues[key]
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        mockValues[key] = value
    }
}

/// Mock reward object for testing
class MockReward: NSManagedObject {
    private var mockValues: [String: Any] = [:]
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: NSEntityDescription(), insertInto: nil)
        setupMockValues()
    }
    
    convenience init() {
        self.init(entity: NSEntityDescription(), insertInto: nil)
    }
    
    private func setupMockValues() {
        mockValues = [
            "id": Int64(1),
            "title": "Test Reward",
            "rewardDescription": "A test reward for unit testing",
            "pointThreshold": Int16(50),
            "isAvailable": true,
            "createdAt": Date(),
            "updatedAt": Date()
        ]
    }
    
    override func value(forKey key: String) -> Any? {
        return mockValues[key]
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        mockValues[key] = value
    }
}

/// Mock penalty object for testing
class MockPenalty: NSManagedObject {
    private var mockValues: [String: Any] = [:]
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: NSEntityDescription(), insertInto: nil)
        setupMockValues()
    }
    
    convenience init() {
        self.init(entity: NSEntityDescription(), insertInto: nil)
    }
    
    private func setupMockValues() {
        mockValues = [
            "id": Int64(1),
            "title": "Test Penalty",
            "penaltyDescription": "A test penalty for unit testing",
            "pointThreshold": Int16(-10),
            "isAvailable": true,
            "createdAt": Date(),
            "updatedAt": Date()
        ]
    }
    
    override func value(forKey key: String) -> Any? {
        return mockValues[key]
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        mockValues[key] = value
    }
}

/// Mock point object for testing
class MockPoint: NSManagedObject {
    private var mockValues: [String: Any] = [:]
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: NSEntityDescription(), insertInto: nil)
        setupMockValues()
    }
    
    convenience init() {
        self.init(entity: NSEntityDescription(), insertInto: nil)
    }
    
    private func setupMockValues() {
        mockValues = [
            "id": Int64(1),
            "currentTotal": Int16(0),
            "dailyTotal": Int16(0),
            "weeklyTotal": Int16(0),
            "monthlyTotal": Int16(0),
            "updatedAt": Date()
        ]
    }
    
    override func value(forKey key: String) -> Any? {
        return mockValues[key]
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        mockValues[key] = value
    }
}

/// Mock point transaction object for testing
class MockPointTransaction: NSManagedObject {
    private var mockValues: [String: Any] = [:]
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: NSEntityDescription(), insertInto: nil)
        setupMockValues()
    }
    
    convenience init() {
        self.init(entity: NSEntityDescription(), insertInto: nil)
    }
    
    private func setupMockValues() {
        mockValues = [
            "id": Int64(1),
            "amount": Int16(10),
            "reason": "Test transaction",
            "transactionType": "chore_completion",
            "createdAt": Date()
        ]
    }
    
    override func value(forKey key: String) -> Any? {
        return mockValues[key]
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        mockValues[key] = value
    }
}
