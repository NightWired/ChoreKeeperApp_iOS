//
//  ChildDashboard.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI
import LocalizationHandler
import ErrorHandler

// Import RefreshTrigger
extension RefreshTrigger {}

struct ChildCorkboardItem: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    @ObservedObject private var refreshTrigger = RefreshTrigger.shared

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 36))
                    .foregroundColor(color)
                    .frame(width: 70, height: 70)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("TextColor"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 100, height: 110)
            .padding(12)
            .background(
                ZStack {
                    // Note paper background with fun color
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)

                    // Fun pattern overlay
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                }
            )
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
            .overlay(
                // Colorful pushpin
                Image(systemName: "pin.fill")
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .offset(y: -10)
                , alignment: .top
            )
            .rotationEffect(.degrees(Double.random(in: -7...7)))
        }
    }
}

struct PointsDisplay: View {
    let points: Int

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)

            Text("\(points)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TextColor"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
        )
    }
}

struct ChildDashboard: View {
    @State private var showLogoutConfirmation = false
    @State private var showSettings = false
    @State private var points = 125 // Example points
    @ObservedObject private var refreshTrigger = RefreshTrigger.shared
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            // Cork board background with a more colorful tint for children
            Color(red: 0.85, green: 0.75, blue: 0.6) // Lighter cork color
                .ignoresSafeArea()
                .overlay(
                    // Cork texture with colorful overlay
                    ZStack {
                        Image("CorkTexture") // You'll need to add this asset
                            .resizable(resizingMode: .tile)
                            .opacity(0.3)
                            .ignoresSafeArea()

                        // Colorful overlay for child-friendly appearance
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.1),
                                Color.purple.opacity(0.1),
                                Color.green.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                    }
                )

            VStack {
                // Header with points display
                HStack {
                    Text(LocalizationHandler.localize("dashboard.child.title"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextColor"))

                    Spacer()

                    // Points display
                    PointsDisplay(points: points)

                    // Settings button
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("SecondaryAccentColor"))
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView(accountType: .child)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                // Cork board content
                ScrollView {
                    VStack(spacing: 25) {
                        // First row - larger, more colorful items for children
                        HStack(spacing: 25) {
                            ChildCorkboardItem(
                                title: LocalizationHandler.localize("dashboard.child.myChores"),
                                systemImage: "checklist",
                                color: Color.blue,
                                action: {
                                    // Navigate to chores
                                }
                            )

                            ChildCorkboardItem(
                                title: LocalizationHandler.localize("dashboard.child.myRewards"),
                                systemImage: "gift.fill",
                                color: Color.purple,
                                action: {
                                    // Navigate to rewards
                                }
                            )
                        }

                        // Second row
                        HStack(spacing: 25) {
                            ChildCorkboardItem(
                                title: LocalizationHandler.localize("dashboard.child.myPoints"),
                                systemImage: "star.fill",
                                color: Color.yellow,
                                action: {
                                    // Navigate to points
                                }
                            )

                            ChildCorkboardItem(
                                title: LocalizationHandler.localize("dashboard.child.achievements"),
                                systemImage: "trophy.fill",
                                color: Color.orange,
                                action: {
                                    // Navigate to achievements
                                }
                            )
                        }


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

struct ChildDashboard_Previews: PreviewProvider {
    static var previews: some View {
        ChildDashboard()
            .environmentObject(AppState())
    }
}
