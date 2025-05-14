//
//  ChoreKeeperApp.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-13.
//

import SwiftUI
import LocalizationHandler

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
}

@main
struct ChoreKeeperApp: App {
    let persistenceController = PersistenceController.shared

    // Initialize the localization service
    let localizationService = LocalizationService()

    // State objects to manage app state and theme
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()

    init() {
        // Register the main bundle for localization
        LocalizationHandler.registerBundle(Bundle.main)

        // Set up localization - explicitly set to English for testing
        localizationService.setLanguage(.english)

        // Print detailed debug information about localization
        print(LocalizationHandler.debugLocalizationInfo())

        #if DEBUG
        // In debug builds, add a delay to allow time to see the console output
        // Store theme value locally to avoid capturing self in closure
        let currentTheme = themeManager.theme.rawValue
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Localization check after delay:")
            print("App name: \(LocalizationHandler.localize("app.name"))")
            print("Add Child: \(LocalizationHandler.localize("children.add"))")
            print("Edit: \(LocalizationHandler.localize("common.edit"))")
            print("Current theme: \(currentTheme)")
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
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    // You can add an environment value for the localization service if needed
                    // .environment(\.localizationService, localizationService)
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
        }
    }
}
