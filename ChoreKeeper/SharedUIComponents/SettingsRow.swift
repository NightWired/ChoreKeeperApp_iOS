//
//  SettingsRow.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI
import LocalizationHandler

/// A reusable settings row component that can be used in settings menus.
/// Supports different types of settings: navigation, toggle, and action.
struct SettingsRow: View {
    // Types of settings rows
    enum RowType {
        case navigation // Row that navigates to another view
        case toggle     // Row with a toggle switch
        case action     // Row that performs an action when tapped
    }

    // Properties
    var icon: String                // SF Symbol name for the icon
    var iconColor: Color            // Color for the icon
    var title: String               // Title text (will be localized)
    var type: RowType               // Type of settings row
    var value: String? = nil        // Optional value text to display (for navigation rows)
    var isOn: Binding<Bool>? = nil  // Binding for toggle state (for toggle rows)
    var action: (() -> Void)? = nil // Action to perform when tapped
    var showNavigationArrow: Bool = true // Whether to show the navigation arrow (for navigation rows)

    var body: some View {
        Group {
            if type == .action {
                // For action type, just return the content without a button
                // This allows the parent view to wrap it in a button
                rowContent
            } else {
                // For navigation and toggle types, use a button
                Button(action: {
                    action?()
                }) {
                    rowContent
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    // Extract the row content to avoid duplication
    private var rowContent: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)

            // Title
            Text(LocalizationHandler.localize(title))
                .foregroundColor(Color("TextColor"))

            Spacer()

            // Different trailing elements based on row type
            switch type {
            case .navigation:
                if let value = value {
                    Text(value)
                        .foregroundColor(Color("SecondaryTextColor"))
                        .font(.subheadline)
                }

                if showNavigationArrow {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Color("SecondaryTextColor"))
                }

            case .toggle:
                if let isOn = isOn {
                    Toggle("", isOn: isOn)
                        .labelsHidden()
                }

            case .action:
                EmptyView()
            }
        }
        .padding(.vertical, 12)
    }
}

struct SettingsRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            // Navigation row
            SettingsRow(
                icon: "globe",
                iconColor: .blue,
                title: "settings.language",
                type: .navigation,
                value: "English"
            )
            .padding(.horizontal)

            Divider()

            // Toggle row
            SettingsRow(
                icon: "moon.fill",
                iconColor: .purple,
                title: "settings.dark_mode",
                type: .toggle,
                isOn: .constant(true)
            )
            .padding(.horizontal)

            Divider()

            // Action row
            SettingsRow(
                icon: "arrow.right.square",
                iconColor: .red,
                title: "common.logout",
                type: .action,
                action: {
                    print("Logout tapped")
                }
            )
            .padding(.horizontal)
        }
        .background(Color("BackgroundColor"))
        .previewLayout(.sizeThatFits)
    }
}
