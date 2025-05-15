import XCTest
@testable import CoreServices

final class CoreServicesTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Initialize CoreServices for testing
        CoreServices.initialize(with: [
            "environment": "testing",
            "featureFlags": [
                "testFeature": true
            ]
        ])
    }

    override func tearDown() {
        // Reset CoreServices after each test
        CoreServices.reset()
        super.tearDown()
    }

    func testConfiguration() {
        // Test configuration initialization
        XCTAssertTrue(Configuration.shared.isConfigured())
        XCTAssertEqual(Configuration.shared.getEnvironment(), .testing)
        XCTAssertTrue(Configuration.shared.isFeatureEnabled("testFeature"))

        // Test configuration value registration
        Configuration.shared.register(value: "test value", for: "testKey")
        XCTAssertEqual(Configuration.shared.getValue(for: "testKey"), "test value")

        // Test feature flag registration
        Configuration.shared.registerFeature(name: "newFeature", isEnabled: true)
        XCTAssertTrue(Configuration.shared.isFeatureEnabled("newFeature"))
    }

    func testLogger() {
        // Test logger initialization
        Logger.setMinimumLogLevel(.debug)

        // These should not throw any errors
        Logger.debug("Debug message")
        Logger.info("Info message")
        Logger.warning("Warning message")
        Logger.error("Error message")
        Logger.critical("Critical message")

        // Test context logging
        Logger.info("Info with context", context: ["key": "value"])
    }

    func testDependencyContainer() {
        // Test dependency registration and resolution
        // Register a dependency
        DependencyContainer.shared.register(String.self) { _ in
            return "test value"
        }

        // Resolve the dependency
        let value = DependencyContainer.shared.resolve(String.self)
        XCTAssertEqual(value, "test value")

        // Test singleton registration
        let singleton = "singleton value"
        DependencyContainer.shared.registerSingleton(String.self, instance: singleton)
        let resolvedSingleton = DependencyContainer.shared.resolve(String.self)
        XCTAssertEqual(resolvedSingleton, singleton)
    }

    func testDateUtilities() {
        // Test date formatting
        let date = Date(timeIntervalSince1970: 0) // January 1, 1970
        let formatted = DateUtilities.format(date, style: .medium)
        XCTAssertFalse(formatted.isEmpty)

        // Test date calculations
        let startOfDay = DateUtilities.startOf(.day, for: date)
        let endOfDay = DateUtilities.endOf(.day, for: date)
        XCTAssertLessThan(startOfDay, endOfDay)

        // Test date extensions
        let tomorrow = date.addingDays(1)
        XCTAssertGreaterThan(tomorrow, date)
    }

    func testStringUtilities() {
        // Test string validation
        XCTAssertTrue(StringUtilities.isValidEmail("test@example.com"))
        XCTAssertFalse(StringUtilities.isValidEmail("invalid-email"))

        // Test string transformation
        XCTAssertEqual(StringUtilities.camelCase("hello world"), "helloWorld")
        XCTAssertEqual(StringUtilities.snakeCase("helloWorld"), "hello_world")

        // Test string extensions
        let email = "test@example.com"
        XCTAssertTrue(email.isValidEmail)
        XCTAssertEqual("hello world".camelCased, "helloWorld")
    }

    func testCollectionExtensions() {
        // Test safe subscript
        let array = [1, 2, 3]
        XCTAssertEqual(array[safe: 1], 2)
        XCTAssertNil(array[safe: 5])

        // Test array extensions
        let chunks = array.chunked(into: 2)
        XCTAssertEqual(chunks.count, 2)
        XCTAssertEqual(chunks[0], [1, 2])
        XCTAssertEqual(chunks[1], [3])

        // Test dictionary extensions
        let dict = ["a": 1, "b": 2]
        let value = dict.value(for: "a", default: 0)
        XCTAssertEqual(value, 1)
        let defaultValue = dict.value(for: "c", default: 0)
        XCTAssertEqual(defaultValue, 0)
    }
}
