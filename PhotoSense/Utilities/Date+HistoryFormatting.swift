import Foundation

extension Date {
    /// A human-readable relative description (e.g. "2 hours ago" or a formatted date).
    func relativeDescription(reference: Date = Date(), calendar: Calendar = .current) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        if calendar.isDate(self, equalTo: reference, toGranularity: .day) ||
            calendar.isDateInYesterday(self) ||
            self > reference.addingTimeInterval(-7 * 24 * 60 * 60) {
            return formatter.localizedString(for: self, relativeTo: reference)
        } else {
            return Date.historyDisplayFormatter.string(from: self)
        }
    }

    /// Title used for grouping history rows into sections.
    func historySectionTitle(reference: Date = Date(), calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(self) {
            return "Today"
        }
        if calendar.isDateInYesterday(self) {
            return "Yesterday"
        }

        let startOfWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: reference)
        let startOfWeek = calendar.date(from: startOfWeekComponents) ?? reference

        if self >= startOfWeek {
            return "This Week"
        }

        return "Earlier"
    }

    static let historyDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
