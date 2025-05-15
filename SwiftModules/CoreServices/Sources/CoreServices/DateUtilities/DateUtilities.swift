import Foundation
import LocalizationHandler

/// Time period for date calculations
public enum TimePeriod {
    case day
    case week
    case month
    case year
    
    /// String representation of the time period
    public var description: String {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        }
    }
    
    /// Localized string representation of the time period
    public var localizedDescription: String {
        switch self {
        case .day:
            return LocalizationHandler.localize("time.period.day")
        case .week:
            return LocalizationHandler.localize("time.period.week")
        case .month:
            return LocalizationHandler.localize("time.period.month")
        case .year:
            return LocalizationHandler.localize("time.period.year")
        }
    }
}

/// Date format style
public enum DateFormatStyle {
    case short
    case medium
    case long
    case full
    case custom(String)
    
    /// Date formatter style
    var dateStyle: DateFormatter.Style {
        switch self {
        case .short:
            return .short
        case .medium:
            return .medium
        case .long:
            return .long
        case .full:
            return .full
        case .custom:
            return .medium
        }
    }
}

/// Utilities for working with dates
public struct DateUtilities {
    
    // MARK: - Date Formatting
    
    /// Format a date with the specified style
    /// - Parameters:
    ///   - date: The date to format
    ///   - style: The format style
    ///   - timeZone: The time zone to use (default: current)
    ///   - locale: The locale to use (default: current)
    /// - Returns: The formatted date string
    public static func format(_ date: Date, style: DateFormatStyle, timeZone: TimeZone = .current, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = locale
        
        switch style {
        case .short, .medium, .long, .full:
            formatter.dateStyle = style.dateStyle
            formatter.timeStyle = .none
        case .custom(let format):
            formatter.dateFormat = format
        }
        
        return formatter.string(from: date)
    }
    
    /// Format a date and time with the specified styles
    /// - Parameters:
    ///   - date: The date to format
    ///   - dateStyle: The date format style
    ///   - timeStyle: The time format style
    ///   - timeZone: The time zone to use (default: current)
    ///   - locale: The locale to use (default: current)
    /// - Returns: The formatted date and time string
    public static func formatDateTime(_ date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, timeZone: TimeZone = .current, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.timeZone = timeZone
        formatter.locale = locale
        
        return formatter.string(from: date)
    }
    
    /// Format a date relative to now (e.g., "2 hours ago", "yesterday")
    /// - Parameters:
    ///   - date: The date to format
    ///   - locale: The locale to use (default: current)
    /// - Returns: The relative date string
    public static func formatRelative(_ date: Date, locale: Locale = .current) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - Date Calculations
    
    /// Get the start of a time period containing the specified date
    /// - Parameters:
    ///   - date: The date
    ///   - period: The time period
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: The start date of the period
    public static func startOf(_ period: TimePeriod, for date: Date, calendar: Calendar = .current) -> Date {
        var components: Set<Calendar.Component>
        
        switch period {
        case .day:
            components = [.year, .month, .day]
        case .week:
            components = [.yearForWeekOfYear, .weekOfYear]
        case .month:
            components = [.year, .month]
        case .year:
            components = [.year]
        }
        
        return calendar.date(from: calendar.dateComponents(components, from: date)) ?? date
    }
    
    /// Get the end of a time period containing the specified date
    /// - Parameters:
    ///   - date: The date
    ///   - period: The time period
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: The end date of the period
    public static func endOf(_ period: TimePeriod, for date: Date, calendar: Calendar = .current) -> Date {
        var components = DateComponents()
        
        switch period {
        case .day:
            components.day = 1
            let startOfNextDay = calendar.date(byAdding: components, to: startOf(.day, for: date, calendar: calendar)) ?? date
            return calendar.date(byAdding: .second, value: -1, to: startOfNextDay) ?? date
        case .week:
            components.weekOfYear = 1
            let startOfNextWeek = calendar.date(byAdding: components, to: startOf(.week, for: date, calendar: calendar)) ?? date
            return calendar.date(byAdding: .second, value: -1, to: startOfNextWeek) ?? date
        case .month:
            components.month = 1
            let startOfNextMonth = calendar.date(byAdding: components, to: startOf(.month, for: date, calendar: calendar)) ?? date
            return calendar.date(byAdding: .second, value: -1, to: startOfNextMonth) ?? date
        case .year:
            components.year = 1
            let startOfNextYear = calendar.date(byAdding: components, to: startOf(.year, for: date, calendar: calendar)) ?? date
            return calendar.date(byAdding: .second, value: -1, to: startOfNextYear) ?? date
        }
    }
    
    /// Calculate the number of days between two dates
    /// - Parameters:
    ///   - startDate: The start date
    ///   - endDate: The end date
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: The number of days between the dates
    public static func daysBetween(_ startDate: Date, _ endDate: Date, calendar: Calendar = .current) -> Int {
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    
    /// Check if a date is within a time period of another date
    /// - Parameters:
    ///   - date: The date to check
    ///   - period: The time period
    ///   - referenceDate: The reference date
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: True if the date is within the time period, false otherwise
    public static func isDate(_ date: Date, within period: TimePeriod, of referenceDate: Date, calendar: Calendar = .current) -> Bool {
        let startDate = startOf(period, for: referenceDate, calendar: calendar)
        let endDate = endOf(period, for: referenceDate, calendar: calendar)
        
        return date >= startDate && date <= endDate
    }
    
    /// Add a time period to a date
    /// - Parameters:
    ///   - period: The time period
    ///   - value: The value to add
    ///   - date: The date to add to
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: The new date
    public static func add(_ period: TimePeriod, value: Int, to date: Date, calendar: Calendar = .current) -> Date {
        var components = DateComponents()
        
        switch period {
        case .day:
            components.day = value
        case .week:
            components.weekOfYear = value
        case .month:
            components.month = value
        case .year:
            components.year = value
        }
        
        return calendar.date(byAdding: components, to: date) ?? date
    }
    
    /// Get the current date and time
    /// - Returns: The current date and time
    public static func now() -> Date {
        return Date()
    }
    
    /// Get today's date (with time set to midnight)
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: Today's date
    public static func today(calendar: Calendar = .current) -> Date {
        return startOf(.day, for: Date(), calendar: calendar)
    }
    
    /// Parse a date string using the specified format
    /// - Parameters:
    ///   - string: The date string
    ///   - format: The date format
    ///   - timeZone: The time zone to use (default: current)
    ///   - locale: The locale to use (default: current)
    /// - Returns: The parsed date, or nil if parsing failed
    public static func parse(_ string: String, format: String, timeZone: TimeZone = .current, locale: Locale = .current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        formatter.locale = locale
        
        return formatter.date(from: string)
    }
}
