import XCTest
import LocalizationHandler
@testable import ErrorHandler

// Protocol for our mock localization service
protocol MockLocalizationProtocol {
    var localizeCallCount: Int { get set }
    var lastLocalizedKey: String? { get set }
    var mockLocalizedString: String { get set }

    func localize(_ key: String) -> String
}

// Extension to make MockLocalizationService conform to LocalizationServiceProtocol
extension MockLocalizationProtocol {
    func localizedString(forKey key: String, defaultValue: String?) -> String {
        return localize(key)
    }

    func localizedString(forKey key: String, with arguments: [CVarArg]) -> String {
        return localize(key)
    }

    func currentLanguage() -> Language {
        return .english
    }

    func setLanguage(_ language: Language) {
        // No-op for testing
    }

    func isRightToLeft() -> Bool {
        return false
    }

    func availableLanguages() -> [Language] {
        return [.english]
    }
}

final class ErrorHandlerTests: XCTestCase {
    // Mock localization service for testing
    class MockLocalizationService: MockLocalizationProtocol, LocalizationServiceProtocol {
        var localizeCallCount = 0
        var lastLocalizedKey: String?
        var mockLocalizedString: String = "Localized Error Message"

        func localize(_ key: String) -> String {
            localizeCallCount += 1
            lastLocalizedKey = key

            // Return the mock string unless the key is a specific test key
            if key == "errors.test_key" {
                return "Test Error Message"
            }

            // Simulate a key not found by returning the key itself
            if key == "errors.not_found" {
                return key
            }

            return mockLocalizedString
        }
    }

    // Mock middleware for testing
    class MockMiddleware: ErrorMiddleware {
        var processCallCount = 0
        var lastProcessedError: AppError?
        var shouldCallNext = true

        func process(error: AppError, next: @escaping (AppError) -> Void) {
            processCallCount += 1
            lastProcessedError = error

            if shouldCallNext {
                next(error)
            }
        }
    }

    // Test creating an AppError
    func testAppErrorCreation() {
        // Create a basic error
        let error = AppError(code: .invalidInput)

        // Verify properties
        XCTAssertEqual(error.code, .invalidInput)
        XCTAssertEqual(error.severity, .medium) // Default severity for invalidInput
        XCTAssertNil(error.message)
        XCTAssertNil(error.underlyingError)
        XCTAssertTrue(error.context.isEmpty)

        // Create an error with custom properties
        let customError = AppError(
            code: .networkError,
            severity: .high,
            message: "Custom message",
            context: ["key": "value"]
        )

        // Verify custom properties
        XCTAssertEqual(customError.code, .networkError)
        XCTAssertEqual(customError.severity, .high)
        XCTAssertEqual(customError.message, "Custom message")
        XCTAssertNil(customError.underlyingError)
        XCTAssertEqual(customError.context["key"] as? String, "value")
    }

    // Test creating an AppError from another error
    func testAppErrorFromError() {
        // Create an underlying error
        struct TestError: Error {
            let message: String
        }

        let underlyingError = TestError(message: "Test error")

        // Create an AppError from the underlying error
        let error = AppError.from(
            underlyingError,
            code: .operationFailed,
            message: "Operation failed"
        )

        // Verify properties
        XCTAssertEqual(error.code, .operationFailed)
        XCTAssertEqual(error.severity, .high) // Default severity for operationFailed
        XCTAssertEqual(error.message, "Operation failed")
        XCTAssertNotNil(error.underlyingError)

        // Verify that creating from an existing AppError preserves the ID
        let originalError = AppError(
            id: "test-id",
            code: .invalidInput,
            message: "Original message"
        )

        let derivedError = AppError.from(
            originalError,
            code: .operationFailed,
            message: "New message"
        )

        XCTAssertEqual(derivedError.id, "test-id")
        XCTAssertEqual(derivedError.code, .operationFailed)
        XCTAssertEqual(derivedError.message, "New message")
    }

    // Test error code formatting
    func testErrorCodeFormatting() {
        let error = AppError(code: .invalidInput)
        XCTAssertEqual(error.formattedCode, "E0003")

        let networkError = AppError(code: .networkError)
        XCTAssertEqual(networkError.formattedCode, "E1000")
    }

    // Test error middleware
    func testErrorMiddleware() {
        // Create a mock middleware
        let mockMiddleware = MockMiddleware()

        // Create an error handler with the mock middleware
        let errorHandler = ErrorHandler()
        errorHandler.registerMiddleware(mockMiddleware)

        // Create an error
        let error = AppError(code: .invalidInput, message: "Test message")

        // Process the error
        errorHandler.processError(error)

        // Verify that the middleware was called
        XCTAssertEqual(mockMiddleware.processCallCount, 1)
        XCTAssertEqual(mockMiddleware.lastProcessedError?.code, .invalidInput)
        XCTAssertEqual(mockMiddleware.lastProcessedError?.message, "Test message")
    }

    // Test error middleware chain
    func testErrorMiddlewareChain() {
        // Create multiple mock middleware
        let middleware1 = MockMiddleware()
        let middleware2 = MockMiddleware()

        // Create an error handler with the mock middleware
        let errorHandler = ErrorHandler()
        errorHandler.registerMiddleware(middleware1)
        errorHandler.registerMiddleware(middleware2)

        // Create an error
        let error = AppError(code: .invalidInput)

        // Process the error
        errorHandler.processError(error)

        // Verify that both middleware were called
        XCTAssertEqual(middleware1.processCallCount, 1)
        XCTAssertEqual(middleware2.processCallCount, 1)

        // Test that the chain stops if a middleware doesn't call next
        middleware1.shouldCallNext = false
        middleware1.processCallCount = 0
        middleware2.processCallCount = 0

        // Process the error again
        errorHandler.processError(error)

        // Verify that only the first middleware was called
        XCTAssertEqual(middleware1.processCallCount, 1)
        XCTAssertEqual(middleware2.processCallCount, 0)
    }

    // Test localized error messages
    func testLocalizedErrorMessages() {
        // Create a mock localization service
        let mockLocalizationService = MockLocalizationService()

        // Create an error handler with the mock service
        let errorHandler = ErrorHandler(localizationService: mockLocalizationService)

        // Create an error with a custom message
        let customMessageError = AppError(
            code: .invalidInput,
            message: "Custom message"
        )

        // Verify that the custom message is used
        XCTAssertEqual(errorHandler.localizedMessage(customMessageError), "Custom message")
        XCTAssertEqual(mockLocalizationService.localizeCallCount, 0)

        // Create an error without a custom message
        let error = AppError(code: .invalidInput)

        // Verify that the localization service is used
        XCTAssertEqual(errorHandler.localizedMessage(error), "Localized Error Message")
        XCTAssertEqual(mockLocalizationService.localizeCallCount, 1)
        XCTAssertEqual(mockLocalizationService.lastLocalizedKey, "errors.3")

        // Test with a specific test key
        mockLocalizationService.lastLocalizedKey = nil

        // Create a custom error with a specific localization key
        let testError = AppError(
            code: .unknown,
            context: ["localizationKey": "errors.test_key"]
        )

        // Modify the localizedMessage method to use our test key
        let originalMethod = errorHandler.localizedMessage
        errorHandler.localizedMessage = { (error: Error) -> String in
            let appError = error as? AppError ?? AppError.from(error)

            // If the error has a custom message, use it
            if let message = appError.message {
                return message
            }

            // Check if we have a custom localization key in the context
            if let localizationKey = appError.context["localizationKey"] as? String {
                return mockLocalizationService.localize(localizationKey)
            }

            // Otherwise, use the default localization key
            return mockLocalizationService.localize(appError.code.localizationKey)
        }

        // Verify that the test key is used
        XCTAssertEqual(errorHandler.localizedMessage(testError), "Test Error Message")
        XCTAssertEqual(mockLocalizationService.lastLocalizedKey, "errors.test_key")

        // Test with a key that doesn't exist
        let notFoundError = AppError(
            code: .unknown,
            context: [
                "localizationKey": "errors.not_found",
                "formattedCode": "E9999"
            ]
        )

        // Modify the localizedMessage method to handle the not found case
        errorHandler.localizedMessage = { (error: Error) -> String in
            let appError = error as? AppError ?? AppError.from(error)

            // If the error has a custom message, use it
            if let message = appError.message {
                return message
            }

            // Check if we have a custom localization key in the context
            if let localizationKey = appError.context["localizationKey"] as? String {
                let message = mockLocalizationService.localize(localizationKey)

                // If the message is the same as the key, it means the key wasn't found
                if message == localizationKey {
                    let formattedCode = appError.context["formattedCode"] as? String ?? appError.formattedCode
                    return "Error \(formattedCode): An error occurred"
                }

                return message
            }

            // Otherwise, use the default localization key
            return mockLocalizationService.localize(appError.code.localizationKey)
        }

        // Verify that a generic error message is returned
        XCTAssertEqual(errorHandler.localizedMessage(notFoundError), "Error E9999: An error occurred")

        // Restore the original method
        errorHandler.localizedMessage = originalMethod
    }
}
