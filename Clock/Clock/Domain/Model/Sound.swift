enum Sound {
    case bell
    case none

    init(path: String) {
        switch path {
        case "bell":
            self = .bell
        default:
            self = .none
        }
    }
}

extension Sound {
    var path: String {
        switch self {
        case .bell:
            "bell"
        case .none:
            ""
        }
    }
}
