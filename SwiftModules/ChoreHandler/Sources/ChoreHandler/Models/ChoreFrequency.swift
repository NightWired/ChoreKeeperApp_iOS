import Foundation

/// Represents the frequency of a recurring chore
public enum ChoreFrequency: String, Codable, CaseIterable {
    /// One-time chore (not recurring)
    case oneTime = "one_time"
    
    /// Daily recurring chore
    case daily = "daily"
    
    /// Weekly recurring chore
    case weekly = "weekly"
    
    /// Monthly recurring chore
    case monthly = "monthly"
    
    /// The display name for the frequency
    public var displayName: String {
        switch self {
        case .oneTime:
            return "One Time"
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        }
    }
    
    /// The localization key for the frequency
    public var localizationKey: String {
        switch self {
        case .oneTime:
            return "chores.frequency.oneTime"
        case .daily:
            return "chores.frequency.daily"
        case .weekly:
            return "chores.frequency.weekly"
        case .monthly:
            return "chores.frequency.monthly"
        }
    }
    
    /// Creates a ChoreFrequency from a recurring pattern string
    /// - Parameter pattern: The recurring pattern string
    /// - Returns: The corresponding ChoreFrequency
    public static func from(pattern: String?) -> ChoreFrequency {
        guard let pattern = pattern else {
            return .oneTime
        }
        
        if pattern.starts(with: "daily") {
            return .daily
        } else if pattern.starts(with: "weekly") {
            return .weekly
        } else if pattern.starts(with: "monthly") {
            return .monthly
        } else {
            return .oneTime
        }
    }
}

/// Represents a day of the week for weekly recurring chores
public enum DayOfWeek: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    /// The display name for the day of the week
    public var displayName: String {
        switch self {
        case .sunday:
            return "Sunday"
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        }
    }
    
    /// The localization key for the day of the week
    public var localizationKey: String {
        switch self {
        case .sunday:
            return "general.daysOfWeek.sunday"
        case .monday:
            return "general.daysOfWeek.monday"
        case .tuesday:
            return "general.daysOfWeek.tuesday"
        case .wednesday:
            return "general.daysOfWeek.wednesday"
        case .thursday:
            return "general.daysOfWeek.thursday"
        case .friday:
            return "general.daysOfWeek.friday"
        case .saturday:
            return "general.daysOfWeek.saturday"
        }
    }
    
    /// The short display name for the day of the week
    public var shortDisplayName: String {
        switch self {
        case .sunday:
            return "Sun"
        case .monday:
            return "Mon"
        case .tuesday:
            return "Tue"
        case .wednesday:
            return "Wed"
        case .thursday:
            return "Thu"
        case .friday:
            return "Fri"
        case .saturday:
            return "Sat"
        }
    }
    
    /// Creates a DayOfWeek from a Calendar.Component.weekday value
    /// - Parameter weekday: The weekday value from Calendar.Component.weekday
    /// - Returns: The corresponding DayOfWeek
    public static func from(weekday: Int) -> DayOfWeek? {
        return DayOfWeek(rawValue: weekday)
    }
    
    /// Gets the current day of the week
    /// - Returns: The current day of the week
    public static func current() -> DayOfWeek {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return DayOfWeek(rawValue: weekday) ?? .sunday
    }
}
