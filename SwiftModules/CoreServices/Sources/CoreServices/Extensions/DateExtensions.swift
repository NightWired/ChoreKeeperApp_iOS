import Foundation

/// Extensions for Date
public extension Date {
    
    /// Get the start of the day for this date
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: The start of the day
    func startOfDay(calendar: Calendar = .current) -> Date {
        return DateUtilities.startOf(.day, for: self, calendar: calendar)
    }
    
    /// Get the end of the day for this date
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: The end of the day
    func endOfDay(calendar: Calendar = .current) -> Date {
        return DateUtilities.endOf(.day, for: self, calendar: calendar)
    }
    
    /// Get the start of the week for this date
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: The start of the week
    func startOfWeek(calendar: Calendar = .current) -> Date {
        return DateUtilities.startOf(.week, for: self, calendar: calendar)
    }
    
    /// Get the end of the week for this date
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: The end of the week
    func endOfWeek(calendar: Calendar = .current) -> Date {
        return DateUtilities.endOf(.week, for: self, calendar: calendar)
    }
    
    /// Get the start of the month for this date
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: The start of the month
    func startOfMonth(calendar: Calendar = .current) -> Date {
        return DateUtilities.startOf(.month, for: self, calendar: calendar)
    }
    
    /// Get the end of the month for this date
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: The end of the month
    func endOfMonth(calendar: Calendar = .current) -> Date {
        return DateUtilities.endOf(.month, for: self, calendar: calendar)
    }
    
    /// Get the start of the year for this date
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: The start of the year
    func startOfYear(calendar: Calendar = .current) -> Date {
        return DateUtilities.startOf(.year, for: self, calendar: calendar)
    }
    
    /// Get the end of the year for this date
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: The end of the year
    func endOfYear(calendar: Calendar = .current) -> Date {
        return DateUtilities.endOf(.year, for: self, calendar: calendar)
    }
    
    /// Add days to this date
    /// - Parameters:
    ///   - days: The number of days to add
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: The new date
    func addingDays(_ days: Int, calendar: Calendar = .current) -> Date {
        return DateUtilities.add(.day, value: days, to: self, calendar: calendar)
    }
    
    /// Add weeks to this date
    /// - Parameters:
    ///   - weeks: The number of weeks to add
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: The new date
    func addingWeeks(_ weeks: Int, calendar: Calendar = .current) -> Date {
        return DateUtilities.add(.week, value: weeks, to: self, calendar: calendar)
    }
    
    /// Add months to this date
    /// - Parameters:
    ///   - months: The number of months to add
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: The new date
    func addingMonths(_ months: Int, calendar: Calendar = .current) -> Date {
        return DateUtilities.add(.month, value: months, to: self, calendar: calendar)
    }
    
    /// Add years to this date
    /// - Parameters:
    ///   - years: The number of years to add
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: The new date
    func addingYears(_ years: Int, calendar: Calendar = .current) -> Date {
        return DateUtilities.add(.year, value: years, to: self, calendar: calendar)
    }
    
    /// Check if this date is today
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: True if today, false otherwise
    func isToday(calendar: Calendar = .current) -> Bool {
        return calendar.isDateInToday(self)
    }
    
    /// Check if this date is yesterday
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: True if yesterday, false otherwise
    func isYesterday(calendar: Calendar = .current) -> Bool {
        return calendar.isDateInYesterday(self)
    }
    
    /// Check if this date is tomorrow
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: True if tomorrow, false otherwise
    func isTomorrow(calendar: Calendar = .current) -> Bool {
        return calendar.isDateInTomorrow(self)
    }
    
    /// Check if this date is in the weekend
    /// - Parameter calendar: The calendar to use (default: current)
    /// - Returns: True if in the weekend, false otherwise
    func isWeekend(calendar: Calendar = .current) -> Bool {
        return calendar.isDateInWeekend(self)
    }
    
    /// Check if this date is in the same day as another date
    /// - Parameters:
    ///   - date: The date to compare with
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: True if in the same day, false otherwise
    func isSameDay(as date: Date, calendar: Calendar = .current) -> Bool {
        return calendar.isDate(self, inSameDayAs: date)
    }
    
    /// Check if this date is in the same week as another date
    /// - Parameters:
    ///   - date: The date to compare with
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: True if in the same week, false otherwise
    func isSameWeek(as date: Date, calendar: Calendar = .current) -> Bool {
        return DateUtilities.isDate(self, within: .week, of: date, calendar: calendar)
    }
    
    /// Check if this date is in the same month as another date
    /// - Parameters:
    ///   - date: The date to compare with
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: True if in the same month, false otherwise
    func isSameMonth(as date: Date, calendar: Calendar = .current) -> Bool {
        return DateUtilities.isDate(self, within: .month, of: date, calendar: calendar)
    }
    
    /// Check if this date is in the same year as another date
    /// - Parameters:
    ///   - date: The date to compare with
    ///   - calendar: The calendar to use (default: current)
    /// - Returns: True if in the same year, false otherwise
    func isSameYear(as date: Date, calendar: Calendar = .current) -> Bool {
        return DateUtilities.isDate(self, within: .year, of: date, calendar: calendar)
    }
    
    /// Format this date with the specified style
    /// - Parameters:
    ///   - style: The format style
    ///   - timeZone: The time zone to use (default: current)
    ///   - locale: The locale to use (default: current)
    /// - Returns: The formatted date string
    func formatted(style: DateFormatStyle, timeZone: TimeZone = .current, locale: Locale = .current) -> String {
        return DateUtilities.format(self, style: style, timeZone: timeZone, locale: locale)
    }
    
    /// Format this date and time with the specified styles
    /// - Parameters:
    ///   - dateStyle: The date format style
    ///   - timeStyle: The time format style
    ///   - timeZone: The time zone to use (default: current)
    ///   - locale: The locale to use (default: current)
    /// - Returns: The formatted date and time string
    func formattedDateTime(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, timeZone: TimeZone = .current, locale: Locale = .current) -> String {
        return DateUtilities.formatDateTime(self, dateStyle: dateStyle, timeStyle: timeStyle, timeZone: timeZone, locale: locale)
    }
    
    /// Format this date relative to now
    /// - Parameter locale: The locale to use (default: current)
    /// - Returns: The relative date string
    func formattedRelative(locale: Locale = .current) -> String {
        return DateUtilities.formatRelative(self, locale: locale)
    }
}
