//
//  ChildDashboard.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-14.
//

import SwiftUI
import LocalizationHandler
import ErrorHandler
import ChoreHandler

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
            .frame(width: 120, height: 110)
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
    @State private var showChoreList = false
    @State private var showChoreCalendar = false
    @State private var showChoreDetail: ChoreModel? = nil
    @State private var points = 125 // Example points

    // Combined sheet state to prevent multiple sheets
    enum ActiveSheet: Identifiable {
        case settings
        case choreList
        case choreCalendar
        case choreDetail(ChoreModel)

        var id: String {
            switch self {
            case .settings: return "settings"
            case .choreList: return "choreList"
            case .choreCalendar: return "choreCalendar"
            case .choreDetail(let chore): return "choreDetail-\(chore.id)"
            }
        }
    }

    @State private var activeSheet: ActiveSheet?
    @State private var previousSheet: ActiveSheet?
    @ObservedObject private var refreshTrigger = RefreshTrigger.shared
    @EnvironmentObject private var appState: AppState

    // Sample chores for demonstration
    @State private var chores: [ChoreModel] = [
        ChoreModel(
            id: 1,
            title: "Clean Room",
            description: "Vacuum and dust the bedroom",
            points: 10,
            dueDate: Date().addingTimeInterval(86400),
            isRecurring: false,
            status: .pending,
            iconId: "room"
        ),
        ChoreModel(
            id: 2,
            title: "Take Out Trash",
            description: "Empty all trash cans",
            points: 5,
            dueDate: Date().addingTimeInterval(3600),
            isRecurring: true,
            recurringPattern: "weekly",
            status: .pending,
            iconId: "trash"
        )
    ]

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
                        activeSheet = .settings
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("SecondaryAccentColor"))
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                // Cork board content
                ScrollView {
                    VStack(spacing: 25) {
                        // First row - larger, more colorful items for children
                        HStack(spacing: 30) {
                            ChildCorkboardItem(
                                title: LocalizationHandler.localize("dashboard.chores_item"),
                                systemImage: "checklist",
                                color: Color.blue,
                                action: {
                                    activeSheet = .choreList
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
                        HStack(spacing: 30) {
                            ChildCorkboardItem(
                                title: LocalizationHandler.localize("dashboard.child.myPoints"),
                                systemImage: "star.fill",
                                color: Color.yellow,
                                action: {
                                    // Navigate to points
                                }
                            )

                            ChildCorkboardItem(
                                title: LocalizationHandler.localize("dashboard.calendar_item"),
                                systemImage: "calendar",
                                color: Color.red,
                                action: {
                                    activeSheet = .choreCalendar
                                }
                            )
                        }

                        // Third row
                        HStack(spacing: 25) {
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
        // Single sheet for all modal presentations
        .sheet(item: $activeSheet) { sheet in
            NavigationView {
                switch sheet {
                case .settings:
                    SettingsView(accountType: .child)

                case .choreList:
                    ChoreList(
                        chores: chores,
                        isParent: false,
                        onChoreSelected: { chore in
                            // Save the current sheet before showing the chore detail
                            previousSheet = .choreList
                            // Delay to ensure proper sheet dismissal before showing the next one
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                activeSheet = .choreDetail(chore)
                            }
                        },
                        onChoreCompleted: { chore in
                            updateChoreStatus(chore, status: .pendingVerification)
                            // In a real app, this would also update points
                            points += Int(chore.points)
                        },
                        onChoreVerified: { _ in
                            // Child can't verify chores
                        },
                        onChoreRejected: { _ in
                            // Child can't reject chores
                        },
                        onAddChore: {
                            // Child can't add chores
                        }
                    )

                case .choreCalendar:
                    ChoreCalendar(
                        chores: chores,
                        isParent: false,
                        onChoreSelected: { chore in
                            // Save the current sheet before showing the chore detail
                            previousSheet = .choreCalendar
                            // Delay to ensure proper sheet dismissal before showing the next one
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                activeSheet = .choreDetail(chore)
                            }
                        },
                        onChoreCompleted: { chore in
                            updateChoreStatus(chore, status: .pendingVerification)
                            // In a real app, this would also update points
                            points += Int(chore.points)
                        },
                        onChoreVerified: { _ in
                            // Child can't verify chores
                        },
                        onChoreRejected: { _ in
                            // Child can't reject chores
                        },
                        onAddChore: {
                            // Child can't add chores
                        }
                    )

                case .choreDetail(let chore):
                    ChoreView(
                        mode: .view,
                        chore: chore,
                        isParent: false,
                        onSave: { _ in
                            // Child can't edit chores
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onDelete: {
                            // Child can't delete chores
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onComplete: {
                            updateChoreStatus(chore, status: .pendingVerification)
                            // In a real app, this would also update points
                            points += Int(chore.points)
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onVerify: {
                            // Child can't verify chores
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onReject: {
                            // Child can't reject chores
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onCancel: {
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Helper Methods

extension ChildDashboard {
    // Update a chore's status
    private func updateChoreStatus(_ chore: ChoreModel, status: ChoreStatus) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            var updatedChore = chores[index]
            updatedChore.status = status
            chores[index] = updatedChore
        }
    }

    // Handle sheet dismissal (for swipe-down gesture)
    private func handleSheetDismissal() {
        // If we have a previous sheet to return to, go there
        if let previous = previousSheet {
            // Small delay to ensure proper transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                activeSheet = previous
                previousSheet = nil
            }
        } else {
            // Otherwise just close the sheet
            activeSheet = nil
        }
    }
}

struct ChildDashboard_Previews: PreviewProvider {
    static var previews: some View {
        ChildDashboard()
            .environmentObject(AppState())
    }
}
