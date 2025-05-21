import Foundation

enum AlarmSection: Hashable {
    case group(AlarmGroupDisplay)
}

struct AlarmGroupDisplay: Hashable {
    let id: UUID
    var name: String
    var order: Int
    var alarms: [AlarmDisplay]

    static func == (lhs: AlarmGroupDisplay, rhs: AlarmGroupDisplay) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AlarmDisplay: Hashable {
    let id: UUID
    var meridiem: String?
    var time: String
    var labelAndRepeatDays: String
    var isEnabled: Bool

    init(alarm: Alarm) {
        self.id = alarm.id
        self.isEnabled = alarm.isEnabled
        self.meridiem = AlarmDisplayFormatter.formatMeridiem(hour: alarm.hour)
        self.time = AlarmDisplayFormatter.formatTime(hour: alarm.hour, minute: alarm.minute)
        self.labelAndRepeatDays = AlarmDisplayFormatter.makeLabelAndRepeatDays(
            label: alarm.label,
            repeatDays: alarm.repeatDays
        )
    }

    static func == (lhs: AlarmDisplay, rhs: AlarmDisplay) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum AlarmDisplayFormatter {
    private static let calendar = Calendar.current

    private static let meridiemFormatter: DateFormatter = {
        let formatter = makeFormatter(dateFormat: "a")
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        return formatter
    }()

    private static let timeFormatter12: DateFormatter = makeFormatter(dateFormat: "h:mm")
    private static let timeFormatter24: DateFormatter = makeFormatter(dateFormat: "H:mm")

    private static let weekdaySymbols: [String] = {
        let formatter = makeFormatter()
        return formatter.shortStandaloneWeekdaySymbols
    }()

    private static func makeFormatter(dateFormat: String? = nil) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        if let dateFormat = dateFormat {
            formatter.dateFormat = dateFormat
        }
        return formatter
    }

    static func formatMeridiem(hour: Int) -> String? {
        guard isUsing12HourFormat() else { return nil }

        let date = calendar.date(from: DateComponents(hour: hour))!

        return meridiemFormatter.string(from: date)
    }

    static func formatTime(hour: Int, minute: Int) -> String {
        let date = calendar.date(from: DateComponents(hour: hour, minute: minute))!

        return isUsing12HourFormat() ? timeFormatter12.string(from: date) : timeFormatter24.string(from: date)
    }

    static func makeLabelAndRepeatDays(label: String, repeatDays: [RepeatDay]) -> String {
        let repeatText = makeRepeatDays(from: repeatDays)

        switch (label.isEmpty, repeatText.isEmpty) {
        case (true, true): return ""
        case (true, false): return repeatText
        case (false, true): return label
        case (false, false): return "\(label), \(repeatText)"
        }
    }

    private static func isUsing12HourFormat() -> Bool {
        let format = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!

        return format.contains("a")
    }

    private static func makeRepeatDays(from repeatDays: [RepeatDay]) -> String {
        guard !repeatDays.isEmpty else { return "" }

        let weekdays = repeatDays.map { $0.weekday }.sorted()

        if weekdays.count == 7 { return "매일" }
        if weekdays == [2, 3, 4, 5, 6] { return "주중" }
        if weekdays == [1, 7] { return "주말" }

        let symbols = weekdays.map { weekdaySymbols[($0 - 1) % 7] }

        if symbols.count > 1 {
            let last = symbols.last!
            let rest = symbols.dropLast().joined(separator: ", ")

            return "\(rest) 및 \(last)"
        } else {
            return symbols.first!
        }
    }
}
