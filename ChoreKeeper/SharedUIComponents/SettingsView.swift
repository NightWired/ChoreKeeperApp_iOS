//
//  SettingsView.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI
import LocalizationHandler
import ErrorHandler
import UIKit

/// A centralized settings view that adapts based on the account type (parent or child).
/// This view displays different settings options depending on the user type.
struct SettingsView: View {
    // Account types
    enum AccountType {
        case parent
        case child
    }

    // Properties
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showLogoutConfirmation = false
    @State private var showDeleteAccountConfirmation = false

    var accountType: AccountType

    var body: some View {
        NavigationView {
            List {
                // Account section
                Section(header: Text(LocalizationHandler.localize("settings.account"))) {
                    // Profile settings
                    NavigationLink(destination: Text("Profile Settings")) {
                        SettingsRow(
                            icon: "person.fill",
                            iconColor: Color("AccentColor"),
                            title: "settings.profile",
                            type: .navigation
                        )
                    }

                    // Avatar settings
                    NavigationLink(destination: Text("Avatar Settings")) {
                        SettingsRow(
                            icon: "person.crop.circle",
                            iconColor: Color("SecondaryAccentColor"),
                            title: "settings.avatar",
                            type: .navigation
                        )
                    }

                    // Security settings (parent only)
                    if accountType == .parent {
                        NavigationLink(destination: Text("Security Settings")) {
                            SettingsRow(
                                icon: "lock.fill",
                                iconColor: .blue,
                                title: "settings.security",
                                type: .navigation
                            )
                        }
                    }
                }

                // Appearance section
                Section(header: Text(LocalizationHandler.localize("settings.appearance"))) {
                    // Theme selector
                    Picker(LocalizationHandler.localize("settings.theme.title"), selection: $themeManager.theme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(LocalizationHandler.localize("settings.theme.\(theme.rawValue)"))
                                .tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 8)

                    // Language selector
                    NavigationLink(destination: EmptyView()) {
                        LanguageSelector(displayMode: .settingsRow)
                    }
                    .disabled(true) // Disable navigation since we're using action sheet
                }

                // Notifications section
                Section(header: Text(LocalizationHandler.localize("settings.notifications"))) {
                    // Notifications toggle
                    SettingsRow(
                        icon: "bell.fill",
                        iconColor: .orange,
                        title: "settings.notifications",
                        type: .toggle,
                        isOn: .constant(true) // Replace with actual binding
                    )

                    // Reminder settings (child only)
                    if accountType == .child {
                        NavigationLink(destination: Text("Reminder Settings")) {
                            SettingsRow(
                                icon: "clock.fill",
                                iconColor: .purple,
                                title: "settings.reminders",
                                type: .navigation
                            )
                        }
                    }
                }

                // Parent-specific settings
                if accountType == .parent {
                    Section(header: Text(LocalizationHandler.localize("settings.chore_management"))) {
                        // Auto-verification toggle
                        SettingsRow(
                            icon: "checkmark.circle.fill",
                            iconColor: .green,
                            title: "settings.auto_verification",
                            type: .toggle,
                            isOn: .constant(false) // Replace with actual binding
                        )

                        // Default due time
                        NavigationLink(destination: Text("Default Due Time Settings")) {
                            SettingsRow(
                                icon: "clock.fill",
                                iconColor: .blue,
                                title: "settings.default_due_time",
                                type: .navigation
                            )
                        }
                    }
                }

                // Help & Support section
                Section(header: Text(LocalizationHandler.localize("settings.help"))) {
                    // About
                    NavigationLink(destination: Text("About ChoreKeeper")) {
                        SettingsRow(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: "settings.about",
                            type: .navigation
                        )
                    }

                    // Privacy Policy
                    NavigationLink(destination: Text("Privacy Policy")) {
                        SettingsRow(
                            icon: "hand.raised.fill",
                            iconColor: .gray,
                            title: "settings.privacy",
                            type: .navigation
                        )
                    }

                    // Terms of Service
                    NavigationLink(destination: Text("Terms of Service")) {
                        SettingsRow(
                            icon: "doc.text.fill",
                            iconColor: .gray,
                            title: "settings.terms",
                            type: .navigation
                        )
                    }
                }

                // Account actions section
                Section {
                    // Logout button
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        SettingsRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            iconColor: .red,
                            title: "common.logout",
                            type: .action
                        )
                    }

                    // Delete account (parent only)
                    if accountType == .parent {
                        Button(action: {
                            showDeleteAccountConfirmation = true
                        }) {
                            SettingsRow(
                                icon: "trash.fill",
                                iconColor: .red,
                                title: "settings.deleteAccount",
                                type: .action
                            )
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(LocalizationHandler.localize("settings.title"))
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text(LocalizationHandler.localize("common.logout")),
                    message: Text(LocalizationHandler.localize("auth.logout_confirmation")),
                    primaryButton: .destructive(Text(LocalizationHandler.localize("common.yes"))) {
                        // Handle logout
                        appState.logout()
                    },
                    secondaryButton: .cancel(Text(LocalizationHandler.localize("common.cancel")))
                )
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Parent settings preview
            SettingsView(accountType: .parent)
                .environmentObject(AppState())
                .environmentObject(ThemeManager())
                .previewDisplayName("Parent Settings")

            // Child settings preview
            SettingsView(accountType: .child)
                .environmentObject(AppState())
                .environmentObject(ThemeManager())
                .previewDisplayName("Child Settings")
        }
    }
}
