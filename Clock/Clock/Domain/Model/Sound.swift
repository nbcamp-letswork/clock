enum Sound {
    case bell
    case none
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
