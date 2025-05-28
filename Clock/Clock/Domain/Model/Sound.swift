enum Sound {
    case bell
    case milkyway
    case sunrise
    case twitter
    case none

    init(path: String) {
        switch path {
        case "bell.caf":
            self = .bell
        case "milkyway.caf":
            self = .milkyway
        case "sunrise.caf":
            self = .sunrise
        case "twitter.caf":
            self = .twitter
        default:
            self = .none
        }
    }
}

extension Sound {
    var path: String {
        switch self {
        case .bell: "bell.caf"
        case .milkyway: "milkyway.caf"
        case .sunrise: "sunrise.caf"
        case .twitter: "twitter.caf"
        case .none: ""
        }
    }
}
