import Foundation

/// Represents a recurring pattern for chores
public struct RecurringPattern: Codable, Equatable {
    /// The frequency of the recurring pattern
    public let frequency: ChoreFrequency

    /// The days of the week for weekly recurring patterns
    public let daysOfWeek: [DayOfWeek]?

    /// The day of the month for monthly recurring patterns
    public let dayOfMonth: Int?

    /// Whether to use the last day of the month for monthly recurring patterns
    public let useLastDayOfMonth: Bool

    /// The hour of the day for the chore to be due (0-23)
    public let dueHour: Int

    /// The minute of the hour for the chore to be due (0-59)
    public let dueMinute: Int

    /// Creates a new recurring pattern
    /// - Parameters:
    ///   - frequency: The frequency of the recurring pattern
    ///   - daysOfWeek: The days of the week for weekly recurring patterns
    ///   - dayOfMonth: The day of the month for monthly recurring patterns
    ///   - useLastDayOfMonth: Whether to use the last day of the month for monthly recurring patterns
    ///   - dueHour: The hour of the day for the chore to be due (0-23)
    ///   - dueMinute: The minute of the hour for the chore to be due (0-59)
    public init(
        frequency: ChoreFrequency,
        daysOfWeek: [DayOfWeek]? = nil,
        dayOfMonth: Int? = nil,
        useLastDayOfMonth: Bool = false,
        dueHour: Int = 22,
        dueMinute: Int = 0
    ) {
        self.frequency = frequency
        self.daysOfWeek = daysOfWeek
        self.dayOfMonth = dayOfMonth
        self.useLastDayOfMonth = useLastDayOfMonth
        self.dueHour = dueHour
        self.dueMinute = dueMinute
    }

    /// Creates a new recurring pattern from a time string
    /// - Parameters:
    ///   - frequency: The frequency of the recurring pattern
    ///   - daysOfWeek: The days of the week for weekly recurring patterns
    ///   - dayOfMonth: The day of the month for monthly recurring patterns
    ///   - useLastDayOfMonth: Whether to use the last day of the month for monthly recurring patterns
    ///   - dueTime: The time of day for the chore to be due (HH:MM format)
    public init(
        frequency: ChoreFrequency,
        daysOfWeek: [DayOfWeek]? = nil,
        dayOfMonth: Int? = nil,
        useLastDayOfMonth: Bool = false,
        dueTime: String = "22:00"
    ) {
        self.frequency = frequency
        self.daysOfWeek = daysOfWeek
        self.dayOfMonth = dayOfMonth
        self.useLastDayOfMonth = useLastDayOfMonth

        // Parse the time string
        let components = dueTime.split(separator: ":")
        if components.count == 2,
           let hours = Int(components[0]),
           let minutes = Int(components[1]),
           hours >= 0 && hours < 24,
           minutes >= 0 && minutes < 60 {
            self.dueHour = hours
            self.dueMinute = minutes
        } else {
            // Default to 10:00 PM if the time string is invalid
            self.dueHour = 22
            self.dueMinute = 0
        }
    }

    /// Creates a daily recurring pattern
    /// - Parameters:
    ///   - dueHour: The hour of the day for the chore to be due (0-23)
    ///   - dueMinute: The minute of the hour for the chore to be due (0-59)
    /// - Returns: A daily recurring pattern
    public static func daily(dueHour: Int = 22, dueMinute: Int = 0) -> RecurringPattern {
        return RecurringPattern(
            frequency: .daily,
            dueHour: dueHour,
            dueMinute: dueMinute
        )
    }

    /// Creates a daily recurring pattern with a time string
    /// - Parameter dueTime: The time of day for the chore to be due (HH:MM format)
    /// - Returns: A daily recurring pattern
    public static func daily(dueTime: String = "22:00") -> RecurringPattern {
        return RecurringPattern(
            frequency: .daily,
            dueTime: dueTime
        )
    }

    /// Creates a weekly recurring pattern
    /// - Parameters:
    ///   - daysOfWeek: The days of the week for the pattern
    ///   - dueHour: The hour of the day for the chore to be due (0-23)
    ///   - dueMinute: The minute of the hour for the chore to be due (0-59)
    /// - Returns: A weekly recurring pattern
    public static func weekly(daysOfWeek: [DayOfWeek], dueHour: Int = 22, dueMinute: Int = 0) -> RecurringPattern {
        return RecurringPattern(
            frequency: .weekly,
            daysOfWeek: daysOfWeek,
            dueHour: dueHour,
            dueMinute: dueMinute
        )
    }

    /// Creates a weekly recurring pattern with a time string
    /// - Parameters:
    ///   - daysOfWeek: The days of the week for the pattern
    ///   - dueTime: The time of day for the chore to be due (HH:MM format)
    /// - Returns: A weekly recurring pattern
    public static func weekly(daysOfWeek: [DayOfWeek], dueTime: String = "22:00") -> RecurringPattern {
        return RecurringPattern(
            frequency: .weekly,
            daysOfWeek: daysOfWeek,
            dueTime: dueTime
        )
    }

    /// Creates a monthly recurring pattern
    /// - Parameters:
    ///   - dayOfMonth: The day of the month for the pattern
    ///   - dueHour: The hour of the day for the chore to be due (0-23)
    ///   - dueMinute: The minute of the hour for the chore to be due (0-59)
    /// - Returns: A monthly recurring pattern
    public static func monthly(dayOfMonth: Int, dueHour: Int = 22, dueMinute: Int = 0) -> RecurringPattern {
        return RecurringPattern(
            frequency: .monthly,
            dayOfMonth: dayOfMonth,
            dueHour: dueHour,
            dueMinute: dueMinute
        )
    }

    /// Creates a monthly recurring pattern with a time string
    /// - Parameters:
    ///   - dayOfMonth: The day of the month for the pattern
    ///   - dueTime: The time of day for the chore to be due (HH:MM format)
    /// - Returns: A monthly recurring pattern
    public static func monthly(dayOfMonth: Int, dueTime: String = "22:00") -> RecurringPattern {
        return RecurringPattern(
            frequency: .monthly,
            dayOfMonth: dayOfMonth,
            dueTime: dueTime
        )
    }

    /// Creates a monthly recurring pattern for the last day of the month
    /// - Parameters:
    ///   - dueHour: The hour of the day for the chore to be due (0-23)
    ///   - dueMinute: The minute of the hour for the chore to be due (0-59)
    /// - Returns: A monthly recurring pattern for the last day of the month
    public static func lastDayOfMonth(dueHour: Int = 22, dueMinute: Int = 0) -> RecurringPattern {
        return RecurringPattern(
            frequency: .monthly,
            useLastDayOfMonth: true,
            dueHour: dueHour,
            dueMinute: dueMinute
        )
    }

    /// Creates a monthly recurring pattern for the last day of the month with a time string
    /// - Parameter dueTime: The time of day for the chore to be due (HH:MM format)
    /// - Returns: A monthly recurring pattern for the last day of the month
    public static func lastDayOfMonth(dueTime: String = "22:00") -> RecurringPattern {
        return RecurringPattern(
            frequency: .monthly,
            useLastDayOfMonth: true,
            dueTime: dueTime
        )
    }

    /// Converts the recurring pattern to a string representation
    /// - Returns: A string representation of the recurring pattern
    public func toString() -> String {
        // Format the time as HH:MM
        let timeString = String(format: "%02d:%02d", dueHour, dueMinute)

        switch frequency {
        case .oneTime:
            return "one_time"

        case .daily:
            return "daily:\(timeString)"

        case .weekly:
            guard let daysOfWeek = daysOfWeek, !daysOfWeek.isEmpty else {
                return "weekly:error"
            }

            let daysString = daysOfWeek
                .sorted { $0.rawValue < $1.rawValue }
                .map { String($0.rawValue) }
                .joined(separator: ",")

            return "weekly:\(daysString):\(timeString)"

        case .monthly:
            if useLastDayOfMonth {
                return "monthly:last:\(timeString)"
            } else if let dayOfMonth = dayOfMonth {
                return "monthly:\(dayOfMonth):\(timeString)"
            } else {
                return "monthly:error"
            }
        }
    }

    /// Parses a string representation of a recurring pattern
    /// - Parameter string: The string representation of the recurring pattern
    /// - Returns: A recurring pattern, or nil if the string is invalid
    public static func fromString(_ string: String) -> RecurringPattern? {
        let components = string.split(separator: ":")

        guard let frequencyString = components.first else {
            return nil
        }

        switch frequencyString {
        case "one_time":
            return RecurringPattern(frequency: .oneTime)

        case "daily":
            let dueTime = components.count > 1 ? String(components[1]) : "22:00"
            return RecurringPattern(frequency: .daily, dueTime: dueTime)

        case "weekly":
            guard components.count >= 2 else {
                return nil
            }

            let daysString = components[1]
            let daysArray = daysString.split(separator: ",")

            var daysOfWeek: [DayOfWeek] = []
            for dayString in daysArray {
                if let dayValue = Int(dayString), let day = DayOfWeek(rawValue: dayValue) {
                    daysOfWeek.append(day)
                }
            }

            let dueTime = components.count > 2 ? String(components[2]) : "22:00"

            return RecurringPattern(
                frequency: .weekly,
                daysOfWeek: daysOfWeek,
                dueTime: dueTime
            )

        case "monthly":
            guard components.count >= 2 else {
                return nil
            }

            let dayString = components[1]
            let dueTime = components.count > 2 ? String(components[2]) : "22:00"

            if dayString == "last" {
                return RecurringPattern(
                    frequency: .monthly,
                    useLastDayOfMonth: true,
                    dueTime: dueTime
                )
            } else if let dayValue = Int(dayString) {
                return RecurringPattern(
                    frequency: .monthly,
                    dayOfMonth: dayValue,
                    dueTime: dueTime
                )
            } else {
                return nil
            }

        default:
            return nil
        }
    }
}
