import XCTest
@testable import LocalizationHandler

final class LocalizationHandlerTests: XCTestCase {
    // MARK: - Properties

    var localizationService: LocalizationService!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        localizationService = LocalizationService()
    }

    override func tearDown() {
        localizationService = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testLanguageEnum() {
        // Test language properties
        XCTAssertEqual(Language.english.rawValue, "en")
        XCTAssertEqual(Language.spanish.rawValue, "es")
        XCTAssertEqual(Language.french.rawValue, "fr")

        // Test language name
        XCTAssertEqual(Language.english.name, "English")
        XCTAssertEqual(Language.spanish.name, "Español")
        XCTAssertEqual(Language.french.name, "Français")

        // Test RTL
        XCTAssertFalse(Language.english.isRightToLeft)
        XCTAssertTrue(Language.arabic.isRightToLeft)

        // Test from locale identifier
        XCTAssertEqual(Language.from(localeIdentifier: "en"), .english)
        XCTAssertEqual(Language.from(localeIdentifier: "es"), .spanish)
        XCTAssertNil(Language.from(localeIdentifier: "invalid"))
    }

    func testLocalizationService() {
        // Test default language
        XCTAssertEqual(localizationService.currentLanguage(), Language.deviceLanguage())

        // Test setting language
        localizationService.setLanguage(.spanish)
        XCTAssertEqual(localizationService.currentLanguage(), .spanish)

        // Test localization
        let welcomeTitle = localizationService.localize("onboarding.welcome.title")
        XCTAssertEqual(welcomeTitle, "Bienvenido a ChoreKeeper")

        // Test localization with arguments
        let greeting = localizationService.localizedString(forKey: "greeting.withName", with: ["John"])
        XCTAssertEqual(greeting, "¡Hola, John!")

        // Test RTL
        XCTAssertFalse(localizationService.isRightToLeft())

        // Test available languages
        XCTAssertEqual(localizationService.availableLanguages().count, Language.allCases.count)
    }

    func testStringExtension() {
        // Set language to English for consistent testing
        localizationService.setLanguage(.english)

        // Test localized string
        XCTAssertEqual("onboarding.welcome.title".localized(), "Welcome to ChoreKeeper")

        // Test localized string with arguments
        XCTAssertEqual("greeting.withName".localized(with: "John"), "Hello, John!")
    }

    func testRTLSupport() {
        // Test with LTR language
        localizationService.setLanguage(.english)
        XCTAssertEqual(RTLSupport.textAlignment(), .leading)
        XCTAssertEqual(RTLSupport.horizontalAlignment(), .leading)
        XCTAssertEqual(RTLSupport.flipIfNeeded(10), 10)

        // Test with RTL language
        localizationService.setLanguage(.arabic)
        XCTAssertEqual(RTLSupport.textAlignment(), .trailing)
        XCTAssertEqual(RTLSupport.horizontalAlignment(), .trailing)
        XCTAssertEqual(RTLSupport.flipIfNeeded(10), -10)
    }

    func testLocalizationParser() {
        let parser = LocalizationParser()

        // Test parsing JSON data
        let jsonString = """
        {
            "test": {
                "key": "value"
            }
        }
        """

        if let data = jsonString.data(using: .utf8),
           let parsedData = parser.parseData(data) {
            XCTAssertNotNil(parsedData)
            XCTAssertEqual(parser.value(for: "test.key", in: parsedData) as? String, "value")
        } else {
            XCTFail("Failed to parse JSON data")
        }
    }
}
