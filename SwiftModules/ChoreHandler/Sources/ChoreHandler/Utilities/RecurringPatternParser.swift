import Foundation

/// Utilities for parsing and generating recurring patterns
public struct RecurringPatternParser {
    /// Parses a recurring pattern string
    /// - Parameter patternString: The pattern string to parse
    /// - Returns: A RecurringPattern object, or nil if the string is invalid
    public static func parse(_ patternString: String) -> RecurringPattern? {
        return RecurringPattern.fromString(patternString)
    }

    /// Generates a recurring pattern string
    /// - Parameter pattern: The RecurringPattern object
    /// - Returns: A string representation of the pattern
    public static func toString(_ pattern: RecurringPattern) -> String {
        return pattern.toString()
    }

    /// Validates a recurring pattern string
    /// - Parameter patternString: The pattern string to validate
    /// - Returns: Whether the pattern string is valid
    public static func isValid(_ patternString: String) -> Bool {
        return parse(patternString) != nil
    }

    /// Gets the frequency from a pattern string
    /// - Parameter patternString: The pattern string
    /// - Returns: The frequency, or .oneTime if the string is invalid
    public static func getFrequency(from patternString: String) -> ChoreFrequency {
        return ChoreFrequency.from(pattern: patternString)
    }

    /// Gets the days of the week from a weekly pattern string
    /// - Parameter patternString: The pattern string
    /// - Returns: An array of days of the week, or nil if the string is not a valid weekly pattern
    public static func getDaysOfWeek(from patternString: String) -> [DayOfWeek]? {
        guard let pattern = parse(patternString), pattern.frequency == .weekly else {
            return nil
        }

        return pattern.daysOfWeek
    }

    /// Gets the day of the month from a monthly pattern string
    /// - Parameter patternString: The pattern string
    /// - Returns: The day of the month, or nil if the string is not a valid monthly pattern
    public static func getDayOfMonth(from patternString: String) -> Int? {
        guard let pattern = parse(patternString), pattern.frequency == .monthly else {
            return nil
        }

        return pattern.dayOfMonth
    }

    /// Checks if a monthly pattern uses the last day of the month
    /// - Parameter patternString: The pattern string
    /// - Returns: Whether the pattern uses the last day of the month, or false if the string is not a valid monthly pattern
    public static func usesLastDayOfMonth(from patternString: String) -> Bool {
        guard let pattern = parse(patternString), pattern.frequency == .monthly else {
            return false
        }

        return pattern.useLastDayOfMonth
    }

    /// Gets the due time from a pattern string
    /// - Parameter patternString: The pattern string
    /// - Returns: The due time string, or "22:00" if the string is invalid or doesn't specify a time
    public static func getDueTime(from patternString: String) -> String {
        guard let pattern = parse(patternString) else {
            return "22:00"
        }

        return String(format: "%02d:%02d", pattern.dueHour, pattern.dueMinute)
    }

    /// Creates a daily pattern string
    /// - Parameter dueTime: The due time (HH:MM format)
    /// - Returns: A daily pattern string
    public static func createDailyPattern(dueTime: String = "22:00") -> String {
        return "daily:\(dueTime)"
    }

    /// Creates a weekly pattern string
    /// - Parameters:
    ///   - daysOfWeek: The days of the week
    ///   - dueTime: The due time (HH:MM format)
    /// - Returns: A weekly pattern string
    public static func createWeeklyPattern(daysOfWeek: [DayOfWeek], dueTime: String = "22:00") -> String {
        let daysString = daysOfWeek
            .sorted { $0.rawValue < $1.rawValue }
            .map { String($0.rawValue) }
            .joined(separator: ",")

        return "weekly:\(daysString):\(dueTime)"
    }

    /// Creates a monthly pattern string for a specific day of the month
    /// - Parameters:
    ///   - dayOfMonth: The day of the month
    ///   - dueTime: The due time (HH:MM format)
    /// - Returns: A monthly pattern string
    public static func createMonthlyPattern(dayOfMonth: Int, dueTime: String = "22:00") -> String {
        return "monthly:\(dayOfMonth):\(dueTime)"
    }

    /// Creates a monthly pattern string for the last day of the month
    /// - Parameter dueTime: The due time (HH:MM format)
    /// - Returns: A monthly pattern string for the last day of the month
    public static func createLastDayOfMonthPattern(dueTime: String = "22:00") -> String {
        return "monthly:last:\(dueTime)"
    }
}
