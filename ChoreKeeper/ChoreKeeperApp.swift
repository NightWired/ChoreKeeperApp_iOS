import SwiftUI
import CoreData
import LocalizationHandler
import ErrorHandler
import CoreServices
import DataModels
import PointsHandler

// Import RefreshTrigger from LoginSelector
extension RefreshTrigger {}

// Environment keys and values are defined in their respective modules

// Extend AppTheme to include UIKit interface style
extension AppTheme {
    var uiInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
}

// No need for a ThemeManager extension anymore as we're handling theme changes through notifications

@main
struct ChoreKeeperApp: App {
    let persistenceController = PersistenceController.shared
    let localizationService = LocalizationService()
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var refreshTrigger = RefreshTrigger.shared

    // Removed isDevelopmentBuild function as it's only used once

    init() {
        // Initialize localization
        LocalizationHandler.registerBundle(Bundle.main)
        if let savedLanguageCode = UserDefaults.standard.string(forKey: "app_language"),
           let savedLanguage = Language.from(localeIdentifier: savedLanguageCode) {
            localizationService.setLanguage(savedLanguage)
        } else {
            localizationService.setLanguage(Language.deviceLanguage())
        }

        // Initialize error handling with minimal configuration
        ErrorHandler.registerMiddleware(LoggingMiddleware())

        // Initialize core services with minimal configuration
        #if DEBUG
        let environment = "development"
        #else
        let environment = "production"
        #endif

        CoreServices.initialize(with: [
            "environment": environment,
            "featureFlags": [
                "enableNewRewards": true,
                "enablePushNotifications": false,
                "enableCloudSync": false,
                "enableAdvancedChoreOptions": true,
                "enableParentalControls": true
            ]
        ])

        // Initialize data models
        let coreDataStack = CoreDataStack(persistentContainer: persistenceController.container)
        DataModels.initialize(with: coreDataStack)

        // Initialize points handler
        let pointsConfig = PointsConfiguration(
            allowNegativeBalances: false,
            maxTransactionHistory: 1000,
            autoResetDailyTotals: true,
            autoResetWeeklyTotals: true,
            autoResetMonthlyTotals: true,
            defaultChorePoints: 10,
            trackCompletionInPeriods: true,
            trackMissedInPeriods: false,
            trackAdjustmentsInPeriods: true
        )
        PointsHandler.initialize(with: pointsConfig)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                if appState.isShowingSplash {
                    SplashScreen {
                        appState.dismissSplash()
                    }
                    .transition(.opacity)
                } else {
                    Group {
                        if appState.isLoggedIn {
                            // Direct navigation to the appropriate dashboard based on user role
                            if UserDefaults.standard.string(forKey: "user_role") == "child" {
                                NavigationStack {
                                    ChildDashboard()
                                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                                        .onAppear {
                                            // Verify correct role
                                            let role = UserDefaults.standard.string(forKey: "user_role")
                                            if role != "child" {
                                                appState.logout()
                                            }
                                        }
                                }
                            } else {
                                NavigationStack {
                                    ParentDashboard()
                                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                                        .onAppear {
                                            // Verify correct role
                                            let role = UserDefaults.standard.string(forKey: "user_role")
                                            if role != "parent" {
                                                appState.logout()
                                            }
                                        }
                                }
                            }
                        } else {
                            NavigationView {
                                LoginSelector()
                                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                                    .navigationBarHidden(true)
                                    // No need for onAppear handler in LoginSelector
                            }
                            .navigationViewStyle(StackNavigationViewStyle())
                        }
                    }
                    .transition(.opacity)
                }
            }
            .environmentObject(appState)
            .environmentObject(themeManager)
            .environmentObject(refreshTrigger)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
                refreshTrigger.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ThemeChanged"))) { _ in
                // Apply theme to UIKit components
                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.windows.forEach { window in
                            window.overrideUserInterfaceStyle = themeManager.theme.uiInterfaceStyle
                        }
                    }
                    refreshTrigger.refresh()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LogoutUser"))) { _ in
                // Perform logout directly here
                DispatchQueue.main.async {
                    // Set isLoggedIn to false first to trigger the onChange handler
                    withAnimation {
                        appState.isLoggedIn = false
                    }

                    // Then call the full logout method to clear user data
                    appState.logout()

                    // Force UI refresh
                    refreshTrigger.refresh()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ReturnToDashboard"))) { notification in
                // Get the user role from the notification or UserDefaults
                let _ = notification.userInfo?["isChildUser"] as? Bool ??
                    (UserDefaults.standard.string(forKey: "user_role") == "child")

                // Force UI refresh to ensure correct dashboard is shown
                DispatchQueue.main.async {
                    refreshTrigger.refresh()
                }
            }
            .onChange(of: appState.isLoggedIn) { newValue in
                // If logged out, reset the navigation
                if !newValue {
                    // Force UI update to ensure we return to LoginSelector
                    DispatchQueue.main.async {
                        self.refreshTrigger.refresh()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.isShowingSplash)
            .animation(.easeInOut(duration: 0.3), value: appState.isLoggedIn)
        }
    }
}