//
//  AppHeaderView.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-18.
//

import SwiftUI
import LocalizationHandler

struct AppHeaderView: View {
    // MARK: - Properties

    let showHomeButton: Bool
    let onHomeButtonTap: () -> Void
    let onSettingsButtonTap: () -> Void
    let isChildUser: Bool

    @State private var showSettings = false
    @State private var showLanguageSelector = false
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var themeManager: ThemeManager

    // MARK: - Initialization

    init(
        showHomeButton: Bool,
        isChildUser: Bool = false,
        onHomeButtonTap: @escaping () -> Void,
        onSettingsButtonTap: @escaping () -> Void
    ) {
        self.showHomeButton = showHomeButton
        self.isChildUser = isChildUser
        self.onHomeButtonTap = onHomeButtonTap
        self.onSettingsButtonTap = onSettingsButtonTap
    }

    // MARK: - Body

    var body: some View {
        HStack {
            // Left side - Home button or spacer
            if showHomeButton {
                Button(action: {
                    print("AppHeaderView: Home button tapped, dismissing sheet and returning to dashboard")

                    // Dismiss settings sheet if open
                    if showSettings {
                        showSettings = false
                    }

                    // Post notification to return to dashboard
                    NotificationCenter.default.post(
                        name: Notification.Name("ReturnToDashboard"),
                        object: nil,
                        userInfo: ["isChildUser": isChildUser]
                    )

                    // Call provided callback for compatibility
                    onHomeButtonTap()
                }) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 22))
                        .foregroundColor(accentColor)
                        .padding(8)
                        .accessibility(label: Text(LocalizationHandler.localize("navigation.home")))
                }
            } else {
                Spacer()
                    .frame(width: 22) // Keep alignment consistent
            }

            Spacer()

            // Right side - Settings button
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundColor(accentColor)
                    .padding(8)
                    .accessibility(label: Text(LocalizationHandler.localize("settings.title")))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color("BackgroundColor"))
        .sheet(isPresented: $showSettings) {
            SettingsView(
                accountType: isChildUser ? .child : .parent,
                onLanguageSelect: {
                    // First dismiss the settings sheet, then show language selector
                    print("AppHeaderView: Language selection requested")
                    showSettings = false

                    // Give time for the settings sheet to dismiss before showing language selector
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showLanguageSelector = true
                    }
                },
                onLogout: {
                    print("AppHeaderView: Logout requested from settings")
                    showSettings = false
                }
            )
            .environmentObject(appState)
            .environmentObject(themeManager)
        }
        .actionSheet(isPresented: $showLanguageSelector) {
            createLanguageActionSheet()
        }
    }

    // MARK: - Helper Properties

    private var accentColor: Color {
        isChildUser ? Color("SecondaryAccentColor") : Color("AccentColor")
    }

    // MARK: - Language Selector

    private func createLanguageActionSheet() -> ActionSheet {
        // Create the action sheet for language selection
        let title = Text(LocalizationHandler.localize("settings.select_language"))
        var buttons: [ActionSheet.Button] = []

        // Get the current language setting
        let currentLanguageCode = UserDefaults.standard.string(forKey: "app_language") ?? "device"

        // Add "Use Device Language" as the first option
        let deviceText = LocalizationHandler.localize("settings.use_device_language")
        let deviceOptionText = currentLanguageCode == "device" ? "✓ \(deviceText)" : deviceText

        buttons.append(.default(Text(deviceOptionText)) {
            LocalizationHandler.setLanguage(Language.deviceLanguage())
            // Save the selection to UserDefaults
            UserDefaults.standard.set("device", forKey: "app_language")
            // Force UI update
            NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        })

        // Add a button for each available language
        for language in LocalizationHandler.availableLanguages() {
            let isSelected = language.rawValue == currentLanguageCode
            let displayText = isSelected ? "✓ \(language.displayName)" : language.displayName

            buttons.append(.default(Text(displayText)) {
                LocalizationHandler.setLanguage(language)
                // Save the selection to UserDefaults
                UserDefaults.standard.set(language.rawValue, forKey: "app_language")
                // Force UI update
                NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
            })
        }

        // Add cancel button
        buttons.append(.cancel(Text(LocalizationHandler.localize("common.cancel"))))

        return ActionSheet(title: title, buttons: buttons)
    }
}

// MARK: - Previews

struct AppHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppHeaderView(
                showHomeButton: false,
                isChildUser: false,
                onHomeButtonTap: {},
                onSettingsButtonTap: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Parent Dashboard Header")

            AppHeaderView(
                showHomeButton: true,
                isChildUser: false,
                onHomeButtonTap: {},
                onSettingsButtonTap: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Parent Sub-view Header")

            AppHeaderView(
                showHomeButton: false,
                isChildUser: true,
                onHomeButtonTap: {},
                onSettingsButtonTap: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Child Dashboard Header")

            AppHeaderView(
                showHomeButton: true,
                isChildUser: true,
                onHomeButtonTap: {},
                onSettingsButtonTap: {}
            )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Child Sub-view Header")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
    }
}