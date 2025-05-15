import XCTest
import CoreData
@testable import DataModels

final class DataModelsTests: XCTestCase {

    func testDataModelsInitialization() {
        // Test that the DataModels class can be initialized
        let dataModels = DataModels.shared
        XCTAssertNotNil(dataModels)
    }

    func testQueryBuilderCreation() {
        // Test that the QueryBuilder can be created
        let query = QueryBuilder<NSManagedObject>()
            .filter(key: "name", value: "Test")
            .sort(key: "name", direction: .ascending)
            .limit(10)

        // We can't build a fetch request without a valid entity name
        // So we'll just test that the query properties are set correctly
        XCTAssertEqual(query.predicates.count, 1)
        XCTAssertEqual(query.sortDescriptors.count, 1)
        XCTAssertEqual(query.fetchLimit, 10)
    }

    func testDataModelErrorConversion() {
        // Test that DataModelError can be converted to AppError
        let error = NSError(domain: "test", code: 123, userInfo: nil)
        let dataModelError = DataModelError.saveFailed(error)
        let appError = dataModelError.toAppError()

        // Verify the conversion
        XCTAssertEqual(appError.code, .dataSaveFailed)
        XCTAssertEqual(appError.severity, .high)
        XCTAssertNotNil(appError.message)
        XCTAssertNotNil(appError.underlyingError)
    }
}
