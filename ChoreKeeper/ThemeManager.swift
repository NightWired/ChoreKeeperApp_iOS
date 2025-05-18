//
//  ThemeManager.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-17.
//

import SwiftUI
import Combine

/// Enum representing the available app themes
enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark
}

/// Class to manage the app's theme
class ThemeManager: ObservableObject {
    /// The current theme
    @Published var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "app_theme")
            updateColorScheme()

            // Post notification for theme change
            NotificationCenter.default.post(name: Notification.Name("ThemeChanged"), object: nil)
        }
    }

    /// The current color scheme
    @Published var colorScheme: ColorScheme?

    /// Initializes the theme manager
    init() {
        // Load saved theme or use system default
        if let savedTheme = UserDefaults.standard.string(forKey: "app_theme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.theme = theme
        } else {
            self.theme = .system
        }

        updateColorScheme()

        // Apply theme to UIKit if the method is available
        // This will be handled by the extension in ChoreKeeperApp.swift
    }

    /// Updates the color scheme based on the current theme
    private func updateColorScheme() {
        switch theme {
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        case .system:
            colorScheme = nil
        }
    }
}
