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
    @State private var navigationPath = NavigationPath()
    @State private var points = 125 // Example points
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
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Header
                AppHeaderView(
                    showHomeButton: false,
                    isChildUser: true,
                    onHomeButtonTap: {},
                    onSettingsButtonTap: { showSettings = true }
                )

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
                        // Points display
                        HStack {
                            Spacer()
                            PointsDisplay(points: points)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)

                        // Cork board content
                        ScrollView {
                            VStack(spacing: 25) {
                                // Add padding at the top
                                Spacer()
                                    .frame(height: 20)
                                // First row - larger, more colorful items for children
                                HStack(spacing: 30) {
                                    ChildCorkboardItem(
                                        title: LocalizationHandler.localize("dashboard.chores_item"),
                                        systemImage: "checklist",
                                        color: Color.blue,
                                        action: {
                                            // Navigate to chore list using standard navigation
                                            print("Child Dashboard: Navigating to ChoreList")
                                            navigationPath.append(AppDestination.choreList)
                                        }
                                    )

                                    ChildCorkboardItem(
                                        title: LocalizationHandler.localize("dashboard.calendar_item"),
                                        systemImage: "calendar",
                                        color: Color.red,
                                        action: {
                                            // Navigate to calendar using standard navigation
                                            print("Child Dashboard: Navigating to ChoreCalendar")
                                            navigationPath.append(AppDestination.choreCalendar)
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
                                        title: LocalizationHandler.localize("dashboard.child.myRewards"),
                                        systemImage: "gift.fill",
                                        color: Color.purple,
                                        action: {
                                            // Navigate to rewards
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
            }
            .navigationBarHidden(true)
            .navigationDestination(for: AppDestination.self) { destination in
                destinationView(for: destination)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ReturnToDashboard"))) { _ in
                print("ChildDashboard: Received ReturnToDashboard notification, resetting navigationPath")
                navigationPath = NavigationPath()
            }
        }
    }

    // MARK: - Helper Methods

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
                isParent: false,
                onChoreSelected: { chore in
                    // Navigate to chore detail
                    print("Child Dashboard: Navigating to ChoreDetail for chore \(chore.id)")
                    navigationPath.append(AppDestination.choreDetail(id: chore.id))
                },
                onChoreCompleted: { chore in
                    updateChoreStatus(chore, status: .pendingVerification)
                    // In a real app, this would also update points
                    points += Int(chore.points)
                },
                onChoreVerified: { _ in
                    // Children can't verify chores
                },
                onChoreRejected: { _ in
                    // Children can't reject chores
                },
                onAddChore: {
                    // Children can't add chores
                }
            )
        case .choreCalendar:
            ChoreCalendar(
                chores: chores,
                isParent: false,
                onChoreSelected: { chore in
                    // Navigate to chore detail
                    print("Child Dashboard: Navigating to ChoreDetail for chore \(chore.id)")
                    navigationPath.append(AppDestination.choreDetail(id: chore.id))
                },
                onChoreCompleted: { chore in
                    updateChoreStatus(chore, status: .pendingVerification)
                    // In a real app, this would also update points
                    points += Int(chore.points)
                },
                onChoreVerified: { _ in
                    // Children can't verify chores
                },
                onChoreRejected: { _ in
                    // Children can't reject chores
                },
                onAddChore: {
                    // Children can't add chores
                }
            )
        case .choreDetail(let id):
            if let chore = chores.first(where: { $0.id == id }) {
                ChoreView(
                    mode: .view,
                    chore: chore,
                    isParent: false,
                    onSave: { _ in
                        // Children can't save chores
                        navigationPath.removeLast()
                    },
                    onDelete: {
                        // Children can't delete chores
                        navigationPath.removeLast()
                    },
                    onComplete: {
                        // Handle complete
                        points += Int(chore.points)
                        navigationPath.removeLast()
                    },
                    onVerify: {
                        // Children can't verify chores
                        navigationPath.removeLast()
                    },
                    onReject: {
                        // Children can't reject chores
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

        default:
            Text("Coming soon!")
                .font(.title)
                .padding()
        }
    }
}

struct ChildDashboard_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChildDashboard()
                .environmentObject(AppState())
        }
    }
}