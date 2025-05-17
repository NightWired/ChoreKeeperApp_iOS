//
//  ChoreListItem.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-16.
//

import SwiftUI
import LocalizationHandler
import ChoreHandler

struct ChoreListItem: View {
    // MARK: - Properties

    var chore: ChoreModel
    var isParent: Bool
    var onComplete: () -> Void
    var onVerify: () -> Void
    var onReject: () -> Void
    var onTap: () -> Void

    @State private var showRejectAlert = false
    @State private var rejectReason = ""

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Chore icon
                Image(systemName: chore.icon.systemName)
                    .font(.system(size: 24))
                    .foregroundColor(statusColor)
                    .frame(width: 40, height: 40)
                    .background(statusColor.opacity(0.2))
                    .clipShape(Circle())

                // Chore details
                VStack(alignment: .leading, spacing: 4) {
                    Text(chore.title)
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))

                    HStack {
                        // Due date
                        Text(formattedDueDate)
                            .font(.subheadline)
                            .foregroundColor(Color("SecondaryTextColor"))

                        Spacer()

                        // Points
                        HStack(spacing: 4) {
                            Text("\(chore.points)")
                                .font(.subheadline)
                                .bold()

                            Text(LocalizationHandler.localize("chores.points"))
                                .font(.caption)
                        }
                        .foregroundColor(Color("AccentColor"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color("AccentColor").opacity(0.1))
                        .cornerRadius(10)
                    }
                }

                Spacer()

                // Status indicator and actions
                statusView
            }
            .padding()
            .background(Color("BackgroundColor"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .id("choreListItem-\(chore.id)") // Ensure unique ID for each list item
        .alert(isPresented: $showRejectAlert) {
            Alert(
                title: Text(LocalizationHandler.localize("chores.rejectReason.title")),
                message: Text(LocalizationHandler.localize("chores.rejectReason.placeholder")),
                primaryButton: .destructive(Text(LocalizationHandler.localize("chores.reject"))) {
                    onReject()
                },
                secondaryButton: .cancel()
            )
        }
    }

    // MARK: - Computed Properties

    private var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: chore.dueDate)
    }

    private var statusColor: Color {
        switch chore.status {
        case .pending:
            return .blue
        case .completed:
            return .green
        case .pendingVerification:
            return .orange
        case .verified:
            return .green
        case .rejected:
            return .red
        case .missed:
            return .gray
        }
    }

    // Helper method to get the correct localization key for status
    private func getStatusLocalizationKey(_ status: ChoreStatus) -> String {
        switch status {
        case .pendingVerification:
            return "chores.status.pendingVerification"
        default:
            return "chores.status.\(status.rawValue)"
        }
    }

    private var statusView: some View {
        Group {
            if chore.status == .pending {
                if !isParent {
                    Button(action: onComplete) {
                        Text(LocalizationHandler.localize("chores.complete"))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                } else {
                    Text(LocalizationHandler.localize("chores.status.pending"))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            } else if chore.status == .pendingVerification && isParent {
                HStack(spacing: 8) {
                    Button(action: onVerify) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 20))
                    }

                    Button(action: { showRejectAlert = true }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                    }
                }
            } else {
                Text(LocalizationHandler.localize(getStatusLocalizationKey(chore.status)))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - Previews

struct ChoreListItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Pending chore for child
            ChoreListItem(
                chore: ChoreModel(
                    id: 1,
                    title: "Clean Room",
                    description: "Vacuum and dust the bedroom",
                    points: 10,
                    dueDate: Date().addingTimeInterval(86400),
                    isRecurring: false,
                    status: .pending,
                    iconId: "room"
                ),
                isParent: false,
                onComplete: {},
                onVerify: {},
                onReject: {},
                onTap: {}
            )

            // Pending verification for parent
            ChoreListItem(
                chore: ChoreModel(
                    id: 2,
                    title: "Take Out Trash",
                    description: "Empty all trash cans",
                    points: 5,
                    dueDate: Date().addingTimeInterval(3600),
                    isRecurring: true,
                    status: .pendingVerification,
                    iconId: "trash"
                ),
                isParent: true,
                onComplete: {},
                onVerify: {},
                onReject: {},
                onTap: {}
            )

            // Completed chore
            ChoreListItem(
                chore: ChoreModel(
                    id: 3,
                    title: "Homework",
                    description: "Math assignment",
                    points: 15,
                    dueDate: Date().addingTimeInterval(-3600),
                    isRecurring: false,
                    status: .completed,
                    iconId: "homework"
                ),
                isParent: false,
                onComplete: {},
                onVerify: {},
                onReject: {},
                onTap: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
