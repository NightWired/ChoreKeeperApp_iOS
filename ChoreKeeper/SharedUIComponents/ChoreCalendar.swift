//
//  ChoreCalendar.swift
//  ChoreKeeper
//
//  Created by Bariby Quance-Hearn on 2025-05-16.
//

import SwiftUI
import LocalizationHandler
import ChoreHandler

struct CalendarDay: Identifiable {
    let id: UUID
    let date: Date?
}

struct ChoreCalendar: View {
    var chores: [ChoreModel]
    var isParent: Bool
    var onChoreSelected: (ChoreModel) -> Void
    var onChoreCompleted: (ChoreModel) -> Void
    var onChoreVerified: (ChoreModel) -> Void
    var onChoreRejected: (ChoreModel) -> Void
    var onAddChore: () -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    @State private var calendarMode: CalendarMode = .month

    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with home button
                AppHeaderView(
                    showHomeButton: true,
                    isChildUser: !isParent,
                    onHomeButtonTap: {
                        presentationMode.wrappedValue.dismiss()
                    },
                    onSettingsButtonTap: {
                        // Show full settings view
                    }
                )

                // Back button and Add button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(LocalizationHandler.localize("common.back"))
                            .foregroundColor(Color("AccentColor"))
                            .padding(.vertical, 8)
                    }

                    Spacer()

                    if isParent {
                        Button(action: {
                            // Navigate to add chore using the callback
                            print("ChoreCalendar: Navigating to AddChore")
                            onAddChore()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle")
                                    .font(.body)
                                Text(LocalizationHandler.localize("chores.add"))
                                    .font(.body)
                            }
                            .foregroundColor(Color("AccentColor"))
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal)

                calendarHeader
                    .padding(.horizontal)
                    .padding(.top, 8)

                switch calendarMode {
                case .month:
                    monthView
                case .week:
                    weekView
                case .day:
                    dayView
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var calendarHeader: some View {
        VStack(spacing: 16) {
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

            Picker("", selection: $calendarMode) {
                Text(LocalizationHandler.localize("chores.calendar.day"))
                    .tag(CalendarMode.day)
                Text(LocalizationHandler.localize("chores.calendar.week"))
                    .tag(CalendarMode.week)
                Text(LocalizationHandler.localize("chores.calendar.month"))
                    .tag(CalendarMode.month)
            }
            .pickerStyle(SegmentedPickerStyle())
            .animation(nil, value: calendarMode)

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
                ForEach(daysInMonth(), id: \.id) { calendarDay in
                    if let date = calendarDay.date {
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isToday = calendar.isDateInToday(date)
                        let dayChores = choresForDate(date)

                        Button(action: {
                            selectedDate = date
                            calendarMode = .day
                        }) {
                            VStack(spacing: 4) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                                    .foregroundColor(isSelected ? .white : (isToday ? Color("AccentColor") : Color("TextColor")))
                                    .frame(width: 30, height: 30)
                                    .background(isSelected ? Color("AccentColor") : (isToday ? Color("AccentColor").opacity(0.1) : Color.clear))
                                    .clipShape(Circle())

                                if !dayChores.isEmpty {
                                    HStack(spacing: 2) {
                                        ForEach(dayChores.prefix(3), id: \.id) { chore in
                                            ChoreCalendarItem(
                                                chore: chore,
                                                size: 20,
                                                onTap: {
                                                    // Navigate to chore detail using the callback
                                                    print("ChoreCalendar: Navigating to ChoreDetail for chore \(chore.id)")
                                                    onChoreSelected(chore)
                                                }
                                            )
                                        }
                                    }

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
                    } else {
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
                ForEach(daysInWeek(for: selectedDate), id: \.hashValue) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(date)
                    let dayChores = choresForDate(date)

                    Button(action: {
                        selectedDate = date
                        calendarMode = .day
                    }) {
                        VStack(spacing: 4) {
                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? .white : (isToday ? Color("AccentColor") : Color("TextColor")))
                                .frame(width: 30, height: 30)
                                .background(isSelected ? Color("AccentColor") : (isToday ? Color("AccentColor").opacity(0.1) : Color.clear))
                                .clipShape(Circle())

                            VStack(spacing: 4) {
                                ForEach(dayChores.prefix(5), id: \.id) { chore in
                                    ChoreCalendarItem(
                                        chore: chore,
                                        size: 24,
                                        onTap: {
                                            // Navigate to chore detail using the callback
                                            print("ChoreCalendar: Navigating to ChoreDetail for chore \(chore.id)")
                                            onChoreSelected(chore)
                                        }
                                    )
                                }

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
                }
            }
            .padding()
        }
    }

    private var dayView: some View {
        VStack(spacing: 16) {
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

            let dayChores = choresForDate(selectedDate)

            if dayChores.isEmpty {
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
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(dayChores, id: \.id) { chore in
                            ChoreListItem(
                                chore: chore,
                                isParent: isParent,
                                onComplete: { onChoreCompleted(chore) },
                                onVerify: { onChoreVerified(chore) },
                                onReject: { onChoreRejected(chore) },
                                onTap: {
                                    // Navigate to chore detail using the callback
                                    print("ChoreCalendar: Navigating to ChoreDetail for chore \(chore.id)")
                                    onChoreSelected(chore)
                                }
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

    private func daysInMonth() -> [CalendarDay] {
        var days = [CalendarDay]()
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        for _ in 1..<firstWeekday {
            days.append(CalendarDay(id: UUID(), date: nil))
        }

        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(CalendarDay(id: UUID(), date: date))
            }
        }

        let remainingCells = (daysInWeek - (days.count % daysInWeek)) % daysInWeek
        for _ in 0..<remainingCells {
            days.append(CalendarDay(id: UUID(), date: nil))
        }

        return days
    }

    private func daysInWeek(for date: Date) -> [Date] {
        let weekday = calendar.component(.weekday, from: date)
        let daysToSubtract = weekday - 1
        guard let firstDayOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: date) else {
            return []
        }

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

enum CalendarMode {
    case day
    case week
    case month
}

struct ChoreCalendar_Previews: PreviewProvider {
    static var previews: some View {
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

        .previewDisplayName("Parent View")

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

        .previewDisplayName("Child View")
    }
}
