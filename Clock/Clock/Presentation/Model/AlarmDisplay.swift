import Foundation

enum AlarmDisplayType {
    case alarm,
         alarmDetail
}

enum AlarmGroupSection: Int, CaseIterable {
    case typing,
         groups
}

enum AlarmSection: Hashable {
    case group(AlarmGroupDisplay)
}

struct AlarmGroupDisplay: Hashable {
    let id: UUID
    var name: String
    var order: Int
    var alarms: [AlarmDisplay]

    init(id: UUID, name: String, order: Int, alarms: [AlarmDisplay]) {
        self.id = id
        self.name = name
        self.order = order
        self.alarms = alarms
    }

    init() {
        self.id = UUID()
        self.name = "기타"
        self.order = 0
        self.alarms = []
    }

    static func == (lhs: AlarmGroupDisplay, rhs: AlarmGroupDisplay) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AlarmDisplay: Hashable {
    let id: UUID
    var time: AlarmTimeDisplay
    var label: AlarmLabelDisplay
    var sound: SoundDisplay
    var isSnooze: Bool
    var isEnabled: Bool
    var repeatDays: AlarmRepeatDaysDisplay

    init(
        id: UUID,
        time: AlarmTimeDisplay,
        label: AlarmLabelDisplay,
        sound: SoundDisplay,
        isSnooze: Bool,
        isEnabled: Bool,
        repeatDays: AlarmRepeatDaysDisplay
    ) {
        self.id = id
        self.time = time
        self.label = label
        self.sound = sound
        self.isSnooze = isSnooze
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
    }

    init() {
        self.id = UUID()
        self.time = .init(raw: Date())
        self.label = .init(raw: "")
        self.sound = .bell
        self.isSnooze = true
        self.isEnabled = true
        self.repeatDays = .init(raw: [])
    }

    var labelAndRepeatDays: String {
        AlarmDisplayFormatter.makeLabelAndRepeatDays(
            label: label.description,
            repeatDays: repeatDays.description
        )
    }

    static func == (lhs: AlarmDisplay, rhs: AlarmDisplay) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AlarmTimeDisplay {
    var raw: Date

    var meridiem: String? {
        AlarmDisplayFormatter.formatMeridiem(time: raw)
    }

    var description: String {
        AlarmDisplayFormatter.formatTime(time: raw)
    }
}

struct AlarmLabelDisplay {
    var raw: String

    var description: String {
        raw.isEmpty ? "알람" : raw
    }

    var detailDescription: String {
        raw
    }
}

enum AlarmWeekdayType: Int, CaseIterable {
    case sunday = 1,
         monday,
         tuesday,
         wednesday,
         thursday,
         friday,
         saturday

    var description: String {
        switch self {
        case .sunday: return "일요일마다"
        case .monday: return "월요일마다"
        case .tuesday: return "화요일마다"
        case .wednesday: return "수요일마다"
        case .thursday: return "목요일마다"
        case .friday: return "금요일마다"
        case .saturday: return "토요일마다"
        }
    }
}

struct AlarmRepeatDaysDisplay {
    var raw: Set<Int>

    var types: [AlarmWeekdayType] {
        raw.compactMap { AlarmWeekdayType(rawValue: $0) }
    }

    var description: String {
        AlarmDisplayFormatter.makeRepeatDays(from: raw, type: .alarm)
    }

    var detailDescription: String {
        AlarmDisplayFormatter.makeRepeatDays(from: raw, type: .alarmDetail)
    }
}

enum AlarmSoundSection: Int, CaseIterable {
    case sound,
         none
}

enum AlarmDisplayFormatter {
    private static let meridiemFormatter: DateFormatter = {
        let formatter = makeFormatter(dateFormat: "a")
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        return formatter
    }()

    private static let timeFormatter12: DateFormatter = makeFormatter(dateFormat: "h:mm")
    private static let timeFormatter24: DateFormatter = makeFormatter(dateFormat: "HH:mm")

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

    static func formatMeridiem(time: Date) -> String? {
        guard isUsing12HourFormat() else { return nil }

        return meridiemFormatter.string(from: time)
    }

    static func formatTime(time: Date) -> String {
        isUsing12HourFormat() ? timeFormatter12.string(from: time) : timeFormatter24.string(from: time)
    }

    static func makeLabelAndRepeatDays(label: String, repeatDays: String) -> String {
        switch (label.isEmpty, repeatDays.isEmpty) {
        case (true, true): return ""
        case (true, false): return repeatDays
        case (false, true): return label
        case (false, false): return "\(label), \(repeatDays)"
        }
    }

    private static func isUsing12HourFormat() -> Bool {
        let format = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!

        return format.contains("a")
    }

    static func makeRepeatDays(from repeatDays: Set<Int>, type: AlarmDisplayType) -> String {
        guard !repeatDays.isEmpty else {
            switch type {
            case .alarm:
                return ""
            case .alarmDetail:
                return "안 함"
            }
        }

        let weekdays = repeatDays.sorted()

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
