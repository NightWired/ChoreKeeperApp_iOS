//
//  ChoreKeeperApp.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-13.
//

import SwiftUI

@main
struct ChoreKeeperApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
