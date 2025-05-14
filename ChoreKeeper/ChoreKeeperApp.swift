//
//  ChoreKeeperApp.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-13.
//

import SwiftUI
import LocalizationHandler

@main
struct ChoreKeeperApp: App {
    let persistenceController = PersistenceController.shared

    // Initialize the localization service
    let localizationService = LocalizationService()

    init() {
        // Register the main bundle for localization
        LocalizationHandler.registerBundle(Bundle.main)

        // Set up localization - explicitly set to English for testing
        localizationService.setLanguage(.english)

        // Print detailed debug information about localization
        print(LocalizationHandler.debugLocalizationInfo())

        #if DEBUG
        // In debug builds, add a delay to allow time to see the console output
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Localization check after delay:")
            print("App name: \(LocalizationHandler.localize("app.name"))")
            print("Add Child: \(LocalizationHandler.localize("children.add"))")
            print("Edit: \(LocalizationHandler.localize("common.edit"))")
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // You can add an environment value for the localization service if needed
                // .environment(\.localizationService, localizationService)
        }
    }
}
