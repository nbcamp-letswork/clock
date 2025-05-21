enum SoundDisplay {
    case bell
    case none
}

enum SoundContext {
    case alarm
    case timer
}

extension SoundDisplay {
    var path: String {
        switch self {
        case .bell:
            "bell"
        case .none:
            ""
        }
    }

    func title(for context: SoundContext) -> String {
        switch (self, context) {
        case (.bell, _):
            return "벨소리"
        case (.none, .alarm):
            return "없음"
        case (.none, .timer):
            return "실행 중단"
        }
    }
}
