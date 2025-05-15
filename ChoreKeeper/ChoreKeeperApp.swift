//
//  ChoreKeeperApp.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-13.
//

import SwiftUI
import CoreData
import LocalizationHandler
import ErrorHandler
import CoreServices
import DataModels

// Import RefreshTrigger from LoginSelector
extension RefreshTrigger {}

// Environment key for CoreServices
private struct CoreServicesEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

// Environment value for CoreServices
extension EnvironmentValues {
    var coreServicesEnabled: Bool {
        get { self[CoreServicesEnabledKey.self] }
        set { self[CoreServicesEnabledKey.self] = newValue }
    }
}

// Environment key for DataModels
private struct DataModelsEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

// Environment value for DataModels
extension EnvironmentValues {
    var dataModelsEnabled: Bool {
        get { self[DataModelsEnabledKey.self] }
        set { self[DataModelsEnabledKey.self] = newValue }
    }
}

// Enum for app theme options
enum AppTheme: String, CaseIterable {
    case light, dark, system

    var uiInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
}

// Theme manager to handle app appearance
class ThemeManager: ObservableObject {
    @Published var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "app_theme")
            applyTheme()
        }
    }

    init() {
        // Load saved theme or default to system
        if let savedTheme = UserDefaults.standard.string(forKey: "app_theme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.theme = theme
        } else {
            // TEMPORARY OVERRIDE FOR TESTING: Set to dark mode by default
            // Change to .system for production
            self.theme = .dark
        }

        // Apply theme immediately on init
        applyTheme()
    }

    func applyTheme() {
        // Apply the selected theme to the app
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = theme.uiInterfaceStyle
            }
        }
    }
}



// State object to manage app state
class AppState: ObservableObject {
    @Published var isShowingSplash = true
    @Published var isAppReady = false
    @Published var isLoggedIn = false
    @Published var resetNavigation = false

    init() {
        // Simulate app initialization time - increased to ensure we have enough time
        // for the splash screen to complete its full animation cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.isAppReady = true
        }
    }

    func dismissSplash() {
        // Only dismiss if app is ready
        if isAppReady {
            withAnimation(.easeOut(duration: 0.8)) { // Increased from 0.3s to 0.8s for smoother transition
                isShowingSplash = false
            }
        } else {
            // If app is not ready yet, wait until it is
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Increased from 0.5s to 1.0s
                withAnimation(.easeOut(duration: 0.8)) { // Increased from 0.3s to 0.8s
                    self.isShowingSplash = false
                }
            }
        }
    }

    func logout() {
        // Reset navigation stack and log out
        self.isLoggedIn = false
        self.resetNavigation = true

        // Reset the flag after a short delay to allow for future navigation resets
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.resetNavigation = false
        }
    }
}

@main
struct ChoreKeeperApp: App {
    let persistenceController = PersistenceController.shared

    // Initialize the localization service
    let localizationService = LocalizationService()

    // State objects to manage app state and theme
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var refreshTrigger = RefreshTrigger.shared

    // Helper method to determine if we're in a development build
    private func isDevelopmentBuild() -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    init() {
        // Register the main bundle for localization
        LocalizationHandler.registerBundle(Bundle.main)

        // Load saved language or use device language
        if let savedLanguageCode = UserDefaults.standard.string(forKey: "app_language"),
           let savedLanguage = Language.from(localeIdentifier: savedLanguageCode) {
            localizationService.setLanguage(savedLanguage)
        } else {
            localizationService.setLanguage(Language.deviceLanguage())
        }

        // Initialize ErrorHandler with default middleware
        ErrorHandler.registerMiddleware(LoggingMiddleware())

        // Create a custom analytics middleware for demonstration
        class DemoAnalyticsService: AnalyticsService {
            func reportError(code: String, message: String, severity: String, timestamp: Date, context: [String: Any]) {
                print("📊 ANALYTICS: Error \(code) (\(severity)) reported: \(message)")
            }
        }

        // Register the analytics middleware
        ErrorHandler.registerMiddleware(AnalyticsMiddleware(analyticsService: DemoAnalyticsService()))

        // Initialize CoreServices module
        CoreServices.initialize(with: [
            "environment": isDevelopmentBuild() ? "development" : "production",
            "featureFlags": [
                "enableNewRewards": true,
                "enablePushNotifications": false, // Disabled since we don't have a developer account
                "enableCloudSync": false,         // Disabled for simulator testing
                "enableAdvancedChoreOptions": true,
                "enableParentalControls": true
            ],
            "api": [
                "baseUrl": "https://api.chorekeeper.com",
                "timeout": 30,
                "retryCount": 3
            ],
            "logging": [
                "minimumLevel": "debug",
                "enableFileLogging": false // Set to true for production
            ]
        ])

        // Configure logger
        Logger.setMinimumLogLevel(isDevelopmentBuild() ? .debug : .info)

        // Initialize DataModels module with the Core Data stack
        let coreDataStack = CoreDataStack(persistentContainer: persistenceController.container)
        DataModels.initialize(with: coreDataStack)

        // Log initialization
        Logger.info("ChoreKeeper app initialized", context: [
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "build": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown",
            "language": localizationService.currentLanguage().rawValue,
            "theme": themeManager.theme.rawValue,
            "modules": ["LocalizationHandler", "ErrorHandler", "CoreServices", "DataModels"]
        ])

        // Print detailed debug information about localization
        print(LocalizationHandler.debugLocalizationInfo())

        #if DEBUG
        // In debug builds, add a delay to allow time to see the console output
        // Store theme value locally to avoid capturing self in closure
        let currentTheme = themeManager.theme.rawValue
        let viewContext = persistenceController.container.viewContext
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Localization check after delay:")
            print("App name: \(LocalizationHandler.localize("app.name"))")
            print("Add Child: \(LocalizationHandler.localize("children.add"))")
            print("Edit: \(LocalizationHandler.localize("common.edit"))")
            print("Current theme: \(currentTheme)")

            // Test error handling and CoreServices during initialization
            Logger.info("Testing error handling and CoreServices during initialization")

            // Test date utilities
            let now = Date()
            let formattedDate = DateUtilities.format(now, style: .medium)
            Logger.info("Current date: \(formattedDate)")

            // Test string utilities
            let email = "test@example.com"
            let isValidEmail = StringUtilities.isValidEmail(email)
            Logger.info("Email validation: \(email) is \(isValidEmail ? "valid" : "invalid")")

            // Test configuration
            let isNewRewardsEnabled = Configuration.shared.isFeatureEnabled("enableNewRewards")
            Logger.info("New rewards feature is \(isNewRewardsEnabled ? "enabled" : "disabled")")

            // Test error handling
            let testError = AppError(code: .unknown, severity: .low, message: "Test error during initialization")
            Logger.log(error: testError)

            // Test DataModels module
            Logger.info("Testing DataModels module during initialization")

            do {
                // Test UserRepository
                let userCount = try UserRepository.shared.count()
                Logger.info("User count: \(userCount)")

                // Test PeriodSettingsRepository
                if let family = try? viewContext.fetch(NSFetchRequest<NSManagedObject>(entityName: "Family")).first {
                    let periodSettings = try PeriodSettingsRepository.shared.getOrCreate(
                        period: "daily",
                        type: "reward",
                        family: family,
                        defaultApplicationMode: "cumulative"
                    )
                    Logger.info("Created period settings with mode: \(periodSettings.value(forKey: "applicationMode") as? String ?? "unknown")")
                }
            } catch {
                Logger.error("Error testing DataModels: \(error.localizedDescription)")
            }
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Background color from assets
                Color("BackgroundColor")
                    .ignoresSafeArea()

                // Main content view
                Group {
                    if appState.resetNavigation {
                        // This is a temporary view that will be shown briefly during navigation reset
                        Color("BackgroundColor").ignoresSafeArea()
                    } else {
                        NavigationView {
                            LoginSelector()
                                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                                // You can add an environment value for the localization service if needed
                                // .environment(\.localizationService, localizationService)
                                .navigationBarHidden(true)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .opacity(appState.isShowingSplash ? 0 : 1)

                // Splash screen
                if appState.isShowingSplash {
                    SplashScreen {
                        // This closure is called when splash screen is ready to dismiss
                        appState.dismissSplash()
                    }
                    .transition(.opacity)
                }
            }
            .environmentObject(appState)
            .environmentObject(themeManager)
            .environmentObject(refreshTrigger)
            // Make CoreServices components available throughout the app
            .environment(\.coreServicesEnabled, true)
            // Make DataModels components available throughout the app
            .environment(\.dataModelsEnabled, true)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
                // Force UI refresh when language changes
                refreshTrigger.refresh()
            }
        }
    }
}
