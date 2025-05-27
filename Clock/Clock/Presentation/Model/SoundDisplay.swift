enum SoundDisplay: CaseIterable {
    case bell
    case milkyway
    case sunrise
    case twitter
    case none
}

enum SoundContext {
    case alarm
    case timer
}

extension SoundDisplay {
    var path: String {
        switch self {
        case .bell: "bell.caf"
        case .milkyway: "milkyway.caf"
        case .sunrise: "sunrise.caf"
        case .twitter: "twitter.caf"
        case .none: ""
        }
    }

    func title(for context: SoundContext) -> String {
        switch (self, context) {
        case (.bell, _):
            return "전화벨(기본 설정)"
        case (.milkyway, _):
            return "은하수"
        case (.sunrise, _):
            return "해뜰녘"
        case (.twitter, _):
            return "지저귐"
        case (.none, .alarm):
            return "없음"
        case (.none, .timer):
            return "실행 중단"
        }
    }
}
