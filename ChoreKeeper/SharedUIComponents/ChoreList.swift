//
//  ChoreList.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-16.
//

import SwiftUI
import LocalizationHandler
import ChoreHandler

struct ChoreList: View {
    // MARK: - Properties

    var chores: [ChoreModel]
    var isParent: Bool
    var onChoreSelected: (ChoreModel) -> Void
    var onChoreCompleted: (ChoreModel) -> Void
    var onChoreVerified: (ChoreModel) -> Void
    var onChoreRejected: (ChoreModel) -> Void
    var onAddChore: () -> Void

    @State private var selectedFilter: ChoreFilter = .all
    @State private var selectedTimeFrame: TimeFrame = .today

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Filter controls
            filterHeader
                .padding(.horizontal)
                .padding(.top)

            if filteredChores.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Chore list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredChores) { chore in
                            ChoreListItem(
                                chore: chore,
                                isParent: isParent,
                                onComplete: { onChoreCompleted(chore) },
                                onVerify: { onChoreVerified(chore) },
                                onReject: { onChoreRejected(chore) },
                                onTap: { onChoreSelected(chore) }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(LocalizationHandler.localize("chores.title"))
        .navigationBarItems(trailing: addButton)
    }

    // MARK: - Subviews

    private var filterHeader: some View {
        VStack(spacing: 16) {
            // Time frame selector
            Picker("", selection: $selectedTimeFrame) {
                Text(LocalizationHandler.localize("chores.timeframe.today"))
                    .tag(TimeFrame.today)
                Text(LocalizationHandler.localize("chores.timeframe.week"))
                    .tag(TimeFrame.thisWeek)
                Text(LocalizationHandler.localize("chores.timeframe.month"))
                    .tag(TimeFrame.thisMonth)
            }
            .pickerStyle(SegmentedPickerStyle())

            // Status filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ChoreFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: LocalizationHandler.localize(getFilterLocalizationKey(filter)),
                            isSelected: selectedFilter == filter,
                            onTap: { selectedFilter = filter }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(Color.gray.opacity(0.5))

            Text(LocalizationHandler.localize("chores.empty"))
                .font(.headline)
                .foregroundColor(Color("PrimaryTextColor"))

            if isParent {
                Button(action: onAddChore) {
                    Text(LocalizationHandler.localize("chores.add_first_chore"))
                        .font(.subheadline)
                        .foregroundColor(Color("AccentColor"))
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var addButton: some View {
        Button(action: onAddChore) {
            Image(systemName: "plus")
                .foregroundColor(Color("AccentColor"))
        }
        .opacity(isParent ? 1.0 : 0.0)
        .disabled(!isParent)
    }

    // MARK: - Helper Methods

    private func getFilterLocalizationKey(_ filter: ChoreFilter) -> String {
        switch filter {
        case .pendingVerification:
            return "chores.filter.pendingVerification"
        default:
            return "chores.filter.\(filter.rawValue)"
        }
    }

    // MARK: - Computed Properties

    private var filteredChores: [ChoreModel] {
        // First filter by time frame
        let timeFilteredChores = chores.filter { chore in
            switch selectedTimeFrame {
            case .today:
                return Calendar.current.isDateInToday(chore.dueDate)
            case .thisWeek:
                return Calendar.current.isDate(chore.dueDate, equalTo: Date(), toGranularity: .weekOfYear)
            case .thisMonth:
                return Calendar.current.isDate(chore.dueDate, equalTo: Date(), toGranularity: .month)
            }
        }

        // Then filter by status
        return timeFilteredChores.filter { chore in
            switch selectedFilter {
            case .all:
                return true
            case .pending:
                return chore.status == .pending
            case .completed:
                return chore.status == .completed || chore.status == .verified
            case .pendingVerification:
                return chore.status == .pendingVerification
            case .missed:
                return chore.status == .missed
            }
        }
    }
}

// MARK: - Supporting Types

enum ChoreFilter: String, CaseIterable {
    case all
    case pending
    case completed
    case pendingVerification
    case missed
}

enum TimeFrame {
    case today
    case thisWeek
    case thisMonth
}

// MARK: - Filter Chip

struct FilterChip: View {
    var title: String
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color("AccentColor") : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : Color("AccentColor"))
                .cornerRadius(16)
        }
    }
}

// MARK: - Previews

struct ChoreList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChoreList(
                chores: [
                    ChoreModel(
                        id: 1,
                        title: "Clean Room",
                        description: "Vacuum and dust the bedroom",
                        points: 10,
                        dueDate: Date(),
                        isRecurring: false,
                        status: .pending,
                        iconId: "room"
                    ),
                    ChoreModel(
                        id: 2,
                        title: "Take Out Trash",
                        description: "Empty all trash cans",
                        points: 5,
                        dueDate: Date(),
                        isRecurring: true,
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
                ],
                isParent: true,
                onChoreSelected: { _ in },
                onChoreCompleted: { _ in },
                onChoreVerified: { _ in },
                onChoreRejected: { _ in },
                onAddChore: {}
            )
        }
        .previewDisplayName("Parent View")

        NavigationView {
            ChoreList(
                chores: [
                    ChoreModel(
                        id: 1,
                        title: "Clean Room",
                        description: "Vacuum and dust the bedroom",
                        points: 10,
                        dueDate: Date(),
                        isRecurring: false,
                        status: .pending,
                        iconId: "room"
                    ),
                    ChoreModel(
                        id: 2,
                        title: "Take Out Trash",
                        description: "Empty all trash cans",
                        points: 5,
                        dueDate: Date(),
                        isRecurring: true,
                        status: .pendingVerification,
                        iconId: "trash"
                    )
                ],
                isParent: false,
                onChoreSelected: { _ in },
                onChoreCompleted: { _ in },
                onChoreVerified: { _ in },
                onChoreRejected: { _ in },
                onAddChore: {}
            )
        }
        .previewDisplayName("Child View")

        NavigationView {
            ChoreList(
                chores: [],
                isParent: true,
                onChoreSelected: { _ in },
                onChoreCompleted: { _ in },
                onChoreVerified: { _ in },
                onChoreRejected: { _ in },
                onAddChore: {}
            )
        }
        .previewDisplayName("Empty State")
    }
}
