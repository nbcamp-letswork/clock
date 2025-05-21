//
//  ClockControlButtonType.swift
//  Clock
//
//  Created by 이수현 on 5/20/25.
//

import UIKit

enum ClockControlButtonType {
    case restartAndStop
    case lap
    case start
    case cancel
}

extension ClockControlButtonType {
    var title: String {
        switch self {
        case .restartAndStop:
            return "재개"
        case .start:
            return "시작"
        case .lap:
            return "랩"
        case .cancel:
            return "취소"
        }
    }

    var selectedTitle: String {
        switch self {
        case .restartAndStop:
            return "일시 정지"
        case .start:
            return "중단"
        case .lap, .cancel:
            return title
        }
    }

    var titleColor: UIColor {
        switch self {
        case .restartAndStop, .start:
            return .green
        case .lap, .cancel:
            return .white
        }
    }

    var selectedTitleColor: UIColor {
        switch self {
        case .restartAndStop:
            return .orange
        case .start:
            return .red
        case .lap:
            return .white
        case .cancel:
            return .white.withAlphaComponent(0.2)
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .restartAndStop, .start:
            return .green.withAlphaComponent(0.2)
        case .lap, .cancel:
            return .gray.withAlphaComponent(0.2)
        }
    }

    var selectedBackgroundColor: UIColor {
        switch self {
        case .restartAndStop:
            return .orange.withAlphaComponent(0.2)
        case .start:
            return .red.withAlphaComponent(0.2)
        case .lap, .cancel:
            return backgroundColor
        }
    }
}
