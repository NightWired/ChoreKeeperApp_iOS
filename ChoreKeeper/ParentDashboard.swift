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
    @State private var navigationPath = NavigationPath()
    @ObservedObject private var refreshTrigger = RefreshTrigger.shared
    @EnvironmentObject private var appState: AppState

    // For debugging
    init() {
        print("ParentDashboard initialized")
    }

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
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Header
                AppHeaderView(
                    showHomeButton: false,
                    isChildUser: false,
                    onHomeButtonTap: {},
                    onSettingsButtonTap: { showSettings = true }
                )

                // Cork board background
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

                    // Cork board content
                    ScrollView {
                        VStack(spacing: 20) {
                            // Add padding at the top
                            Spacer()
                                .frame(height: 20)
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
                                        // Navigate to chore list using standard navigation
                                        print("Navigating to ChoreList")
                                        navigationPath.append(AppDestination.choreList)
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
                                        // Navigate to calendar using standard navigation
                                        print("Navigating to ChoreCalendar")
                                        navigationPath.append(AppDestination.choreCalendar)
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
            .navigationDestination(for: AppDestination.self) { destination in
                destinationView(for: destination)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ReturnToDashboard"))) { _ in
                print("ParentDashboard: Received ReturnToDashboard notification, resetting navigationPath")
                navigationPath = NavigationPath()
            }
        }
    }

    // MARK: - Helper Methods

    // Add a new chore to the list
    func addChore(_ chore: ChoreModel) {
        chores.append(chore)
    }

    // Update an existing chore
    func updateChore(_ updatedChore: ChoreModel) {
        if let index = chores.firstIndex(where: { $0.id == updatedChore.id }) {
            chores[index] = updatedChore
        }
    }

    // Delete a chore
    func deleteChore(_ chore: ChoreModel) {
        chores.removeAll { $0.id == chore.id }
    }

    // Update a chore's status
    func updateChoreStatus(_ chore: ChoreModel, status: ChoreStatus) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            var updatedChore = chores[index]
            updatedChore.status = status
            chores[index] = updatedChore
        }
    }

    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .choreList:
            ChoreList(
                chores: chores,
                isParent: true,
                onChoreSelected: { chore in
                    // Navigate to chore detail
                    print("Navigating to ChoreDetail for chore \(chore.id)")
                    navigationPath.append(AppDestination.choreDetail(id: chore.id))
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
                    // Navigate to add chore
                    print("Navigating to AddChore")
                    navigationPath.append(AppDestination.addChore)
                }
            )
        case .choreCalendar:
            ChoreCalendar(
                chores: chores,
                isParent: true,
                onChoreSelected: { chore in
                    // Navigate to chore detail
                    print("Navigating to ChoreDetail for chore \(chore.id)")
                    navigationPath.append(AppDestination.choreDetail(id: chore.id))
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
                    // Navigate to add chore
                    print("Navigating to AddChore")
                    navigationPath.append(AppDestination.addChore)
                }
            )
        case .choreDetail(let id):
            if let chore = chores.first(where: { $0.id == id }) {
                ChoreView(
                    mode: .view,
                    chore: chore,
                    isParent: true,
                    onSave: { updatedChore in
                        // Handle save
                        navigationPath.removeLast()
                    },
                    onDelete: {
                        // Handle delete
                        navigationPath.removeLast()
                    },
                    onComplete: {
                        // Handle complete
                        navigationPath.removeLast()
                    },
                    onVerify: {
                        // Handle verify
                        navigationPath.removeLast()
                    },
                    onReject: {
                        // Handle reject
                        navigationPath.removeLast()
                    },
                    onCancel: {
                        navigationPath.removeLast()
                    }
                )
                .navigationBarHidden(true)
            } else {
                Text("Chore not found")
                    .font(.title)
                    .padding()
            }

        case .addChore:
            ChoreView(
                mode: .create,
                isParent: true,
                onSave: { newChore in
                    // Handle save new chore
                    navigationPath.removeLast()
                },
                onDelete: {
                    navigationPath.removeLast()
                },
                onComplete: {
                    navigationPath.removeLast()
                },
                onVerify: {
                    navigationPath.removeLast()
                },
                onReject: {
                    navigationPath.removeLast()
                },
                onCancel: {
                    navigationPath.removeLast()
                }
            )
            .navigationBarHidden(true)

        default:
            Text("Coming soon!")
                .font(.title)
                .padding()
        }
    }
}

struct ParentDashboard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ParentDashboard()
                .environmentObject(AppState())
        }
    }
}