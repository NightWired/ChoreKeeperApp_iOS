//
//  ParentDashboard.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI
import LocalizationHandler
import ErrorHandler

// Import RefreshTrigger
extension RefreshTrigger {}

struct CorkboardItem: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    @ObservedObject private var refreshTrigger = RefreshTrigger.shared

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                    .frame(width: 60, height: 60)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("TextColor"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 90, height: 100)
            .padding(10)
            .background(
                ZStack {
                    // Note paper background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)

                    // Subtle lined paper effect
                    VStack(spacing: 8) {
                        ForEach(0..<8) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 1)
                        }
                    }
                    .mask(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                    )
                }
            )
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
            .overlay(
                // Pushpin
                Image(systemName: "pin.fill")
                    .font(.system(size: 16))
                    .foregroundColor(color)
                    .offset(y: -8)
                , alignment: .top
            )
            .rotationEffect(.degrees(Double.random(in: -5...5)))
        }
    }
}

struct ParentDashboard: View {
    @State private var showLogoutConfirmation = false
    @State private var showSettings = false
    @ObservedObject private var refreshTrigger = RefreshTrigger.shared
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            // Cork board background
            Color(red: 0.82, green: 0.69, blue: 0.52) // Cork color
                .ignoresSafeArea()
                .overlay(
                    // Cork texture
                    Image("CorkTexture") // You'll need to add this asset
                        .resizable(resizingMode: .tile)
                        .opacity(0.3)
                        .ignoresSafeArea()
                )

            VStack {
                // Header
                HStack {
                    Text(LocalizationHandler.localize("dashboard.parent.title"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextColor"))

                    Spacer()

                    // Settings button
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("AccentColor"))
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView(accountType: .parent)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                // Cork board content
                ScrollView {
                    VStack(spacing: 20) {
                        // First row
                        HStack(spacing: 20) {
                            CorkboardItem(
                                title: LocalizationHandler.localize("dashboard.parent.children"),
                                systemImage: "person.3.fill",
                                color: Color.blue,
                                action: {
                                    // Navigate to children management
                                }
                            )

                            CorkboardItem(
                                title: LocalizationHandler.localize("dashboard.parent.chores"),
                                systemImage: "checklist",
                                color: Color.green,
                                action: {
                                    // Navigate to chores management
                                }
                            )

                            CorkboardItem(
                                title: LocalizationHandler.localize("dashboard.parent.rewards"),
                                systemImage: "gift.fill",
                                color: Color.purple,
                                action: {
                                    // Navigate to rewards management
                                }
                            )
                        }

                        // Second row
                        HStack(spacing: 20) {
                            CorkboardItem(
                                title: LocalizationHandler.localize("dashboard.parent.statistics"),
                                systemImage: "chart.bar.fill",
                                color: Color.orange,
                                action: {
                                    // Navigate to statistics
                                }
                            )

                            CorkboardItem(
                                title: LocalizationHandler.localize("dashboard.parent.calendar"),
                                systemImage: "calendar",
                                color: Color.red,
                                action: {
                                    // Navigate to calendar
                                }
                            )

                            CorkboardItem(
                                title: LocalizationHandler.localize("dashboard.parent.family"),
                                systemImage: "house.fill",
                                color: Color(red: 0.2, green: 0.5, blue: 0.8),
                                action: {
                                    // Navigate to family management
                                }
                            )
                        }

                        // Additional items can be added here
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showLogoutConfirmation) {
            Alert(
                title: Text(LocalizationHandler.localize("common.logout")),
                message: Text(LocalizationHandler.localize("auth.logout_confirmation")),
                primaryButton: .destructive(Text(LocalizationHandler.localize("common.yes"))) {
                    // Handle logout using the app state
                    appState.logout()
                },
                secondaryButton: .cancel(Text(LocalizationHandler.localize("common.cancel")))
            )
        }
    }
}

struct ParentDashboard_Previews: PreviewProvider {
    static var previews: some View {
        ParentDashboard()
            .environmentObject(AppState())
    }
}
