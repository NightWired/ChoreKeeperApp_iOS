import Foundation

/// Utilities for working with dates
public struct DateUtilities {
    /// Gets the start of the day for a date
    /// - Parameter date: The date
    /// - Returns: The start of the day
    public static func startOfDay(for date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

    /// Gets the end of the day for a date
    /// - Parameter date: The date
    /// - Returns: The end of the day
    public static func endOfDay(for date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay(for: date))!
    }

    /// Gets the start of the week for a date
    /// - Parameter date: The date
    /// - Returns: The start of the week
    public static func startOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components)!
    }

    /// Gets the end of the week for a date
    /// - Parameter date: The date
    /// - Returns: The end of the week
    public static func endOfWeek(for date: Date) -> Date {
        var components = DateComponents()
        components.day = 7
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek(for: date))!
    }

    /// Gets the start of the month for a date
    /// - Parameter date: The date
    /// - Returns: The start of the month
    public static func startOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }

    /// Gets the end of the month for a date
    /// - Parameter date: The date
    /// - Returns: The end of the month
    public static func endOfMonth(for date: Date) -> Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth(for: date))!
    }

    /// Gets the start of the next month for a date
    /// - Parameter date: The date
    /// - Returns: The start of the next month
    public static func startOfNextMonth(for date: Date) -> Date {
        var components = DateComponents()
        components.month = 1
        return Calendar.current.date(byAdding: components, to: startOfMonth(for: date))!
    }

    /// Gets the end of the next month for a date
    /// - Parameter date: The date
    /// - Returns: The end of the next month
    public static func endOfNextMonth(for date: Date) -> Date {
        var components = DateComponents()
        components.month = 2
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth(for: date))!
    }

    /// Gets the day of the week for a date
    /// - Parameter date: The date
    /// - Returns: The day of the week
    public static func dayOfWeek(for date: Date) -> DayOfWeek? {
        let weekday = Calendar.current.component(.weekday, from: date)
        return DayOfWeek(rawValue: weekday)
    }

    /// Gets the day of the month for a date
    /// - Parameter date: The date
    /// - Returns: The day of the month
    public static func dayOfMonth(for date: Date) -> Int {
        return Calendar.current.component(.day, from: date)
    }

    /// Gets the month for a date
    /// - Parameter date: The date
    /// - Returns: The month (1-12)
    public static func month(for date: Date) -> Int {
        return Calendar.current.component(.month, from: date)
    }

    /// Gets the year for a date
    /// - Parameter date: The date
    /// - Returns: The year
    public static func year(for date: Date) -> Int {
        return Calendar.current.component(.year, from: date)
    }

    /// Gets the last day of the month for a date
    /// - Parameter date: The date
    /// - Returns: The last day of the month
    public static func lastDayOfMonth(for date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.upperBound - 1
    }

    /// Gets the last day of the month
    /// - Parameters:
    ///   - month: The month (1-12)
    ///   - year: The year
    /// - Returns: The last day of the month
    public static func lastDayOfMonth(month: Int, year: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        let calendar = Calendar.current
        let date = calendar.date(from: components)!

        return lastDayOfMonth(for: date)
    }

    /// Gets the next occurrence of a day of the week
    /// - Parameters:
    ///   - dayOfWeek: The day of the week
    ///   - fromDate: The date to start from
    /// - Returns: The next occurrence of the day of the week
    public static func nextOccurrenceOfDay(dayOfWeek: DayOfWeek, fromDate: Date) -> Date {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: fromDate)
        let daysToAdd = (dayOfWeek.rawValue - currentWeekday + 7) % 7

        // If today is the target day and we're looking for the next occurrence,
        // we need to add 7 days instead of 0
        let adjustedDaysToAdd = daysToAdd == 0 ? 7 : daysToAdd

        var components = DateComponents()
        components.day = adjustedDaysToAdd

        return calendar.date(byAdding: components, to: startOfDay(for: fromDate))!
    }

    /// Gets the next occurrence of a day of the month
    /// - Parameters:
    ///   - dayOfMonth: The day of the month
    ///   - fromDate: The date to start from
    /// - Returns: The next occurrence of the day of the month
    public static func nextOccurrenceOfDayOfMonth(dayOfMonth: Int, fromDate: Date) -> Date {
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: fromDate)
        let currentMonth = calendar.component(.month, from: fromDate)
        let currentYear = calendar.component(.year, from: fromDate)

        var components = DateComponents()
        components.year = currentYear
        components.month = currentMonth
        components.day = dayOfMonth

        // If the target day is in the current month and is after the current day,
        // or if the target day is the current day and we're looking for the next occurrence,
        // we can use the current month
        if dayOfMonth > currentDay {
            let date = calendar.date(from: components)!
            return startOfDay(for: date)
        }

        // Otherwise, we need to move to the next month
        components.month = currentMonth + 1

        // Adjust for month overflow
        if components.month! > 12 {
            components.month = 1
            components.year = currentYear + 1
        }

        // Adjust for days that don't exist in the target month
        let lastDayOfTargetMonth = lastDayOfMonth(month: components.month!, year: components.year!)
        if dayOfMonth > lastDayOfTargetMonth {
            components.day = lastDayOfTargetMonth
        }

        let date = calendar.date(from: components)!
        return startOfDay(for: date)
    }

    /// Gets the next occurrence of the last day of the month
    /// - Parameter fromDate: The date to start from
    /// - Returns: The next occurrence of the last day of the month
    public static func nextOccurrenceOfLastDayOfMonth(fromDate: Date) -> Date {
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: fromDate)
        let lastDayOfCurrentMonth = lastDayOfMonth(for: fromDate)

        // If today is not the last day of the month, or if we're looking for the next occurrence,
        // we can use the current month's last day
        if currentDay < lastDayOfCurrentMonth {
            return endOfMonth(for: fromDate)
        }

        // Otherwise, we need to move to the next month
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: fromDate)!
        return endOfMonth(for: nextMonth)
    }

    /// Parses a time string to hours and minutes
    /// - Parameter timeString: The time string (HH:MM format)
    /// - Returns: A tuple containing the hours and minutes, or nil if the string is invalid
    public static func parseTimeString(_ timeString: String) -> (hours: Int, minutes: Int)? {
        print("Parsing time string: \(timeString)")
        let components = timeString.split(separator: ":")
        print("Components: \(components)")

        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]),
              hours >= 0 && hours < 24,
              minutes >= 0 && minutes < 60 else {
            print("Failed to parse time string: \(timeString)")
            return nil
        }

        print("Parsed time: \(hours):\(minutes)")
        return (hours: hours, minutes: minutes)
    }

    /// Sets the time for a date
    /// - Parameters:
    ///   - date: The date
    ///   - timeString: The time string (HH:MM format)
    /// - Returns: The date with the specified time, or nil if the time string is invalid
    public static func setTime(for date: Date, timeString: String) -> Date? {
        guard let (hours, minutes) = parseTimeString(timeString) else {
            return nil
        }

        return setTime(for: date, hour: hours, minute: minutes)
    }

    /// Sets the time for a date
    /// - Parameters:
    ///   - date: The date
    ///   - hour: The hour (0-23)
    ///   - minute: The minute (0-59)
    /// - Returns: The date with the specified time
    public static func setTime(for date: Date, hour: Int, minute: Int) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        components.second = 0

        return calendar.date(from: components)
    }
}
