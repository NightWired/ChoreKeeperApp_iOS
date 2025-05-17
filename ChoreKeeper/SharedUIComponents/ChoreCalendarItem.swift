//
//  ChoreCalendarItem.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-16.
//

import SwiftUI
import LocalizationHandler
import ChoreHandler

struct ChoreCalendarItem: View {
    // MARK: - Properties

    var chore: ChoreModel
    var size: CGFloat = 40
    var onTap: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomTrailing) {
                // Chore icon
                Image(systemName: chore.icon.systemName)
                    .font(.system(size: size * 0.5))
                    .foregroundColor(.white)
                    .frame(width: size, height: size)
                    .background(statusColor)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)

                // Status indicator
                if chore.status != .pending {
                    Image(systemName: statusIcon)
                        .font(.system(size: size * 0.3))
                        .foregroundColor(.white)
                        .frame(width: size * 0.4, height: size * 0.4)
                        .background(statusBadgeColor)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .offset(x: 2, y: 2)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(PlainButtonStyle())
        .id("choreCalendarItem-\(chore.id)")
    }

    // MARK: - Computed Properties

    private var statusColor: Color {
        switch chore.status {
        case .pending:
            return .blue
        case .completed, .verified:
            return .green
        case .pendingVerification:
            return .orange
        case .rejected:
            return .red
        case .missed:
            return .gray
        }
    }

    private var statusBadgeColor: Color {
        switch chore.status {
        case .completed, .verified:
            return .green
        case .pendingVerification:
            return .orange
        case .rejected:
            return .red
        case .missed:
            return .gray
        default:
            return .blue
        }
    }

    private var statusIcon: String {
        switch chore.status {
        case .completed, .verified:
            return "checkmark"
        case .pendingVerification:
            return "clock"
        case .rejected:
            return "xmark"
        case .missed:
            return "exclamationmark"
        default:
            return ""
        }
    }
}

// MARK: - Previews

struct ChoreCalendarItem_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            // Pending chore
            ChoreCalendarItem(
                chore: ChoreModel(
                    id: 1,
                    title: "Clean Room",
                    points: 10,
                    dueDate: Date(),
                    status: .pending,
                    iconId: "room"
                ),
                size: 50,
                onTap: {}
            )

            // Completed chore
            ChoreCalendarItem(
                chore: ChoreModel(
                    id: 2,
                    title: "Take Out Trash",
                    points: 5,
                    dueDate: Date(),
                    status: .completed,
                    iconId: "trash"
                ),
                size: 50,
                onTap: {}
            )

            // Pending verification
            ChoreCalendarItem(
                chore: ChoreModel(
                    id: 3,
                    title: "Homework",
                    points: 15,
                    dueDate: Date(),
                    status: .pendingVerification,
                    iconId: "homework"
                ),
                size: 50,
                onTap: {}
            )

            // Rejected chore
            ChoreCalendarItem(
                chore: ChoreModel(
                    id: 4,
                    title: "Dishes",
                    points: 8,
                    dueDate: Date(),
                    status: .rejected,
                    iconId: "dishes"
                ),
                size: 50,
                onTap: {}
            )

            // Missed chore
            ChoreCalendarItem(
                chore: ChoreModel(
                    id: 5,
                    title: "Laundry",
                    points: 12,
                    dueDate: Date(),
                    status: .missed,
                    iconId: "laundry"
                ),
                size: 50,
                onTap: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
