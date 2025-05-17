//
//  ParentDashboard.swift
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
            .frame(width: 110, height: 100)
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
    @State private var showChoreList = false
    @State private var showChoreCalendar = false
    @State private var showChoreDetail: ChoreModel? = nil
    @State private var showCreateChore = false

    // Combined sheet state to prevent multiple sheets
    enum ActiveSheet: Identifiable {
        case settings
        case choreList
        case choreCalendar
        case choreDetail(ChoreModel)
        case createChore

        var id: String {
            switch self {
            case .settings: return "settings"
            case .choreList: return "choreList"
            case .choreCalendar: return "choreCalendar"
            case .choreDetail(let chore): return "choreDetail-\(chore.id)"
            case .createChore: return "createChore"
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
            status: .pendingVerification,
            iconId: "trash"
        ),
        ChoreModel(
            id: 3,
            title: "Homework",
            description: "Math assignment",
            points: 15,
            dueDate: Date().addingTimeInterval(-3600),
            isRecurring: false,
            status: .completed,
            iconId: "homework"
        )
    ]

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
                        activeSheet = .settings
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("AccentColor"))
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
                    VStack(spacing: 20) {
                        // First row
                        HStack(spacing: 25) {
                            CorkboardItem(
                                title: LocalizationHandler.localize("dashboard.parent.children"),
                                systemImage: "person.3.fill",
                                color: Color.blue,
                                action: {
                                    // Navigate to children management
                                }
                            )

                            CorkboardItem(
                                title: LocalizationHandler.localize("dashboard.chores_item"),
                                systemImage: "checklist",
                                color: Color.green,
                                action: {
                                    activeSheet = .choreList
                                }
                            )
                        }

                        // Second row
                        HStack(spacing: 25) {
                            CorkboardItem(
                                title: LocalizationHandler.localize("dashboard.calendar_item"),
                                systemImage: "calendar",
                                color: Color.red,
                                action: {
                                    activeSheet = .choreCalendar
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

                        // Third row
                        HStack(spacing: 25) {
                            CorkboardItem(
                                title: LocalizationHandler.localize("dashboard.parent.statistics"),
                                systemImage: "chart.bar.fill",
                                color: Color.orange,
                                action: {
                                    // Navigate to statistics
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
        // Single sheet for all modal presentations
        .sheet(item: $activeSheet) { sheet in
            NavigationView {
                switch sheet {
                case .settings:
                    SettingsView(accountType: .parent)

                case .choreList:
                    ChoreList(
                        chores: chores,
                        isParent: true,
                        onChoreSelected: { chore in
                            // Save the current sheet before showing the chore detail
                            previousSheet = .choreList
                            // Delay to ensure proper sheet dismissal before showing the next one
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                activeSheet = .choreDetail(chore)
                            }
                        },
                        onChoreCompleted: { chore in
                            updateChoreStatus(chore, status: .completed)
                        },
                        onChoreVerified: { chore in
                            updateChoreStatus(chore, status: .verified)
                        },
                        onChoreRejected: { chore in
                            updateChoreStatus(chore, status: .rejected)
                        },
                        onAddChore: {
                            // Save the current sheet before showing create chore
                            previousSheet = .choreList
                            // Delay to ensure proper sheet dismissal before showing the next one
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                activeSheet = .createChore
                            }
                        }
                    )

                case .choreCalendar:
                    ChoreCalendar(
                        chores: chores,
                        isParent: true,
                        onChoreSelected: { chore in
                            // Save the current sheet before showing the chore detail
                            previousSheet = .choreCalendar
                            // Delay to ensure proper sheet dismissal before showing the next one
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                activeSheet = .choreDetail(chore)
                            }
                        },
                        onChoreCompleted: { chore in
                            updateChoreStatus(chore, status: .completed)
                        },
                        onChoreVerified: { chore in
                            updateChoreStatus(chore, status: .verified)
                        },
                        onChoreRejected: { chore in
                            updateChoreStatus(chore, status: .rejected)
                        },
                        onAddChore: {
                            // Save the current sheet before showing create chore
                            previousSheet = .choreCalendar
                            // Delay to ensure proper sheet dismissal before showing the next one
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                activeSheet = .createChore
                            }
                        }
                    )

                case .choreDetail(let chore):
                    ChoreView(
                        mode: .view,
                        chore: chore,
                        isParent: true,
                        onSave: { updatedChore in
                            updateChore(updatedChore)
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onDelete: {
                            deleteChore(chore)
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onComplete: {
                            updateChoreStatus(chore, status: .completed)
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onVerify: {
                            updateChoreStatus(chore, status: .verified)
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onReject: {
                            updateChoreStatus(chore, status: .rejected)
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

                case .createChore:
                    ChoreView(
                        mode: .create,
                        isParent: true,
                        onSave: { newChore in
                            addChore(newChore)
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onDelete: {
                            // Not used in create mode
                            // Return to previous sheet
                            if let previous = previousSheet {
                                activeSheet = previous
                            } else {
                                activeSheet = nil
                            }
                        },
                        onComplete: {
                            // Not used in create mode
                        },
                        onVerify: {
                            // Not used in create mode
                        },
                        onReject: {
                            // Not used in create mode
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

extension ParentDashboard {
    // Add a new chore to the list
    private func addChore(_ chore: ChoreModel) {
        chores.append(chore)
    }

    // Update an existing chore
    private func updateChore(_ updatedChore: ChoreModel) {
        if let index = chores.firstIndex(where: { $0.id == updatedChore.id }) {
            chores[index] = updatedChore
        }
    }

    // Delete a chore
    private func deleteChore(_ chore: ChoreModel) {
        chores.removeAll { $0.id == chore.id }
    }

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

struct ParentDashboard_Previews: PreviewProvider {
    static var previews: some View {
        ParentDashboard()
            .environmentObject(AppState())
    }
}
