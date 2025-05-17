//
//  ChoreCalendar.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-16.
//

import SwiftUI
import LocalizationHandler
import ChoreHandler

struct ChoreCalendar: View {
    // MARK: - Properties

    var chores: [ChoreModel]
    var isParent: Bool
    var onChoreSelected: (ChoreModel) -> Void
    var onChoreCompleted: (ChoreModel) -> Void
    var onChoreVerified: (ChoreModel) -> Void
    var onChoreRejected: (ChoreModel) -> Void
    var onAddChore: () -> Void

    @State private var selectedDate = Date()
    @State private var calendarMode: CalendarMode = .month

    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Calendar header
            calendarHeader
                .padding(.horizontal)
                .padding(.top)

            // Calendar view
            switch calendarMode {
            case .month:
                monthView
            case .week:
                weekView
            case .day:
                dayView
            }
        }
        .navigationTitle(LocalizationHandler.localize("chores.title"))
        .navigationBarItems(trailing: addButton)
    }

    // MARK: - Subviews

    private var calendarHeader: some View {
        VStack(spacing: 16) {
            // Month and year display with navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color("AccentColor"))
                }

                Spacer()

                Text(monthYearString)
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color("AccentColor"))
                }
            }

            // Calendar mode selector
            Picker("", selection: $calendarMode) {
                Text(LocalizationHandler.localize("chores.calendar.day"))
                    .tag(CalendarMode.day)
                Text(LocalizationHandler.localize("chores.calendar.week"))
                    .tag(CalendarMode.week)
                Text(LocalizationHandler.localize("chores.calendar.month"))
                    .tag(CalendarMode.month)
            }
            .pickerStyle(SegmentedPickerStyle())

            // Day of week headers (for month and week views)
            if calendarMode != .day {
                HStack {
                    ForEach(0..<daysInWeek, id: \.self) { index in
                        Text(dayOfWeekLetter(for: index))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color("SecondaryTextColor"))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    private var monthView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isToday = calendar.isDateInToday(date)
                        let dayChores = choresForDate(date)

                        Button(action: {
                            selectedDate = date
                            calendarMode = .day
                        }) {
                            VStack(spacing: 4) {
                                // Day number
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                                    .foregroundColor(isSelected ? .white : (isToday ? Color("AccentColor") : Color("TextColor")))
                                    .frame(width: 30, height: 30)
                                    .background(isSelected ? Color("AccentColor") : (isToday ? Color("AccentColor").opacity(0.1) : Color.clear))
                                    .clipShape(Circle())

                                // Chore indicators (up to 3)
                                if !dayChores.isEmpty {
                                    HStack(spacing: 2) {
                                        ForEach(dayChores.prefix(3), id: \.id) { chore in
                                            ChoreCalendarItem(
                                                chore: chore,
                                                size: 20,
                                                onTap: { onChoreSelected(chore) }
                                            )
                                        }
                                    }

                                    // Show count if more than 3
                                    if dayChores.count > 3 {
                                        Text("+\(dayChores.count - 3)")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color("SecondaryTextColor"))
                                    }
                                }

                                Spacer()
                            }
                            .frame(height: 70)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .id("calendarDay-\(date.hashValue)")
                    } else {
                        // Empty cell for days not in current month
                        Color.clear
                            .frame(height: 70)
                    }
                }
            }
            .padding()
        }
    }

    private var weekView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInWeek(for: selectedDate), id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(date)
                    let dayChores = choresForDate(date)

                    Button(action: {
                        selectedDate = date
                        calendarMode = .day
                    }) {
                        VStack(spacing: 4) {
                            // Day number
                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? .white : (isToday ? Color("AccentColor") : Color("TextColor")))
                                .frame(width: 30, height: 30)
                                .background(isSelected ? Color("AccentColor") : (isToday ? Color("AccentColor").opacity(0.1) : Color.clear))
                                .clipShape(Circle())

                            // Chores for the day
                            VStack(spacing: 4) {
                                ForEach(dayChores.prefix(5), id: \.id) { chore in
                                    ChoreCalendarItem(
                                        chore: chore,
                                        size: 24,
                                        onTap: { onChoreSelected(chore) }
                                    )
                                }

                                // Show count if more than 5
                                if dayChores.count > 5 {
                                    Text("+\(dayChores.count - 5)")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color("SecondaryTextColor"))
                                }
                            }

                            Spacer()
                        }
                        .frame(height: 200)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .id("calendarWeekDay-\(date.hashValue)")
                }
            }
            .padding()
        }
    }

    private var dayView: some View {
        VStack(spacing: 16) {
            // Selected day header
            HStack {
                VStack(alignment: .leading) {
                    Text(dayOfWeekString)
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))

                    Text(dayMonthString)
                        .font(.subheadline)
                        .foregroundColor(Color("SecondaryTextColor"))
                }

                Spacer()

                // Today button
                if !calendar.isDateInToday(selectedDate) {
                    Button(action: {
                        selectedDate = Date()
                    }) {
                        Text(LocalizationHandler.localize("common.today"))
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("AccentColor"))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)

            // Chores for the selected day
            let dayChores = choresForDate(selectedDate)

            if dayChores.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Spacer()

                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundColor(Color.gray.opacity(0.5))

                    Text(LocalizationHandler.localize("chores.calendar.noChoresForDate"))
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))

                    if isParent {
                        Button(action: onAddChore) {
                            Text(LocalizationHandler.localize("chores.calendar.addForDate"))
                                .font(.subheadline)
                                .foregroundColor(Color("AccentColor"))
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                // List of chores
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(dayChores) { chore in
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

    private func daysInMonth() -> [Date?] {
        var days = [Date?]()

        // Get the first day of the month
        let firstDayOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: selectedDate)
        )!

        // Get the weekday of the first day (1-7, where 1 is Sunday)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }

        // Get the number of days in the month
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count

        // Add a cell for each day in the month
        for day in 1...daysInMonth {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
            days.append(date)
        }

        // Add empty cells to complete the last week if needed
        let remainingCells = (daysInWeek - (days.count % daysInWeek)) % daysInWeek
        for _ in 0..<remainingCells {
            days.append(nil)
        }

        return days
    }

    private func daysInWeek(for date: Date) -> [Date] {
        // Get the first day of the week containing the given date
        let weekday = calendar.component(.weekday, from: date)
        let daysToSubtract = weekday - 1 // Adjust to get Sunday as the first day

        guard let firstDayOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: date) else {
            return []
        }

        // Create an array of the 7 days in the week
        var days = [Date]()
        for day in 0..<daysInWeek {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDayOfWeek) {
                days.append(date)
            }
        }

        return days
    }

    private func dayOfWeekLetter(for index: Int) -> String {
        let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
        return daysOfWeek[index]
    }

    private func choresForDate(_ date: Date) -> [ChoreModel] {
        return chores.filter { chore in
            calendar.isDate(chore.dueDate, inSameDayAs: date)
        }
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    // MARK: - Computed Properties

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    private var dayOfWeekString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }

    private var dayMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Supporting Types

enum CalendarMode {
    case day
    case week
    case month
}

// MARK: - Previews

struct ChoreCalendar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChoreCalendar(
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
                        dueDate: Date().addingTimeInterval(86400),
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
            ChoreCalendar(
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
    }
}
