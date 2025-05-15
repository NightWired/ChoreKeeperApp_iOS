//
//  LanguageSelector.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI
import LocalizationHandler

// Class to trigger UI refreshes when language changes (moved from LoginSelector)
class RefreshTrigger: ObservableObject {
    static let shared = RefreshTrigger()

    @Published var refreshID = UUID()

    func refresh() {
        refreshID = UUID()
    }
}

/// A reusable language selector component that can be displayed as either an icon button
/// or a settings row, depending on the context.
struct LanguageSelector: View {
    // Display mode for the language selector
    enum DisplayMode {
        case iconButton  // For login screens (globe icon)
        case settingsRow // For settings menu (row with text and icon)
    }

    // Properties
    @State private var showLanguageSelector = false
    @ObservedObject var refreshTrigger = RefreshTrigger.shared
    var displayMode: DisplayMode
    var iconColor: Color = Color("AccentColor")
    var backgroundColor: Color = Color("BackgroundColor")

    var body: some View {
        Group {
            switch displayMode {
            case .iconButton:
                // Icon button for login screens
                Button(action: {
                    showLanguageSelector = true
                }) {
                    Image(systemName: "globe")
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                        .padding(8)
                        .background(backgroundColor)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }

            case .settingsRow:
                // Settings row for settings menu
                Button(action: {
                    showLanguageSelector = true
                }) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 20))
                            .foregroundColor(iconColor)

                        Text(LocalizationHandler.localize("settings.language"))
                            .foregroundColor(Color("TextColor"))

                        Spacer()

                        // Show currently selected language
                        HStack(spacing: 4) {
                            // Get current language setting
                            let currentLanguageCode = UserDefaults.standard.string(forKey: "app_language") ?? "device"
                            let displayText = currentLanguageCode == "device"
                                ? LocalizationHandler.localize("settings.use_device_language")
                                : LocalizationHandler.currentLanguage().displayName

                            Text(displayText)
                                .foregroundColor(Color("SecondaryTextColor"))
                                .font(.subheadline)
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(Color("SecondaryTextColor"))
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .actionSheet(isPresented: $showLanguageSelector) {
            ActionSheet(
                title: Text(LocalizationHandler.localize("settings.select_language")),
                buttons: languageButtons()
            )
        }
        .id("languageSelector_\(refreshTrigger.refreshID)")
    }

    private func languageButtons() -> [ActionSheet.Button] {
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

        return buttons
    }
}

struct LanguageSelector_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Preview icon button mode
            LanguageSelector(displayMode: .iconButton)
                .previewDisplayName("Icon Button Mode")

            // Preview settings row mode
            LanguageSelector(displayMode: .settingsRow)
                .padding(.horizontal)
                .previewDisplayName("Settings Row Mode")
        }
        .padding()
        .background(Color("BackgroundColor"))
    }
}
