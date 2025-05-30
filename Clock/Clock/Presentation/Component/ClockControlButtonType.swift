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
    case startAndStop
    case cancel
    case startAndStopImage
    case startImage
}

extension ClockControlButtonType {
    var title: String? {
        switch self {
        case .restartAndStop:
            return "재개"
        case .startAndStop:
            return "시작"
        case .lap:
            return "랩"
        case .cancel:
            return "취소"
        default:
            return nil
        }
    }

    var selectedTitle: String? {
        switch self {
        case .restartAndStop:
            return "일시 정지"
        case .startAndStop:
            return "중단"
        case .cancel:
            return title
        default:
            return nil
        }
    }

    var titleColor: UIColor? {
        switch self {
        case .restartAndStop, .startAndStop:
            return .green
        case .lap, .cancel:
            return .white
        default:
            return nil
        }
    }

    var selectedTitleColor: UIColor? {
        switch self {
        case .restartAndStop:
            return .orange
        case .startAndStop:
            return .red
        case .lap:
            return .white
        case .cancel:
            return .white.withAlphaComponent(0.2)
        default:
            return nil
        }
    }

    var disabledTitleColor: UIColor? {
        switch self {
        case .restartAndStop, .startAndStop:
            return .green
        case .lap:
            return .lightGray
        case .cancel:
            return .white
        default:
            return nil
        }
    }
    
    var backgroundColor: UIColor? {
        switch self {
        case .restartAndStop, .startAndStop, .startImage:
            return .green.withAlphaComponent(0.2)
        case .lap, .cancel:
            return .gray.withAlphaComponent(0.2)
        default:
            return nil
        }
    }

    var selectedBackgroundColor: UIColor? {
        switch self {
        case .restartAndStop:
            return .orange.withAlphaComponent(0.2)
        case .startAndStop:
            return .red.withAlphaComponent(0.2)
        case .lap, .cancel:
            return backgroundColor
        default:
            return nil
        }
    }

    var image: UIImage? {
        switch self {
        case .startAndStopImage:
            return .init(systemName: "play.circle")
        case .startImage:
            return .init(systemName: "play.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
        default:
            return nil
        }
    }

    var selectedImage: UIImage? {
        switch self {
        case .startAndStopImage:
            return .init(systemName: "pause.circle")
        default:
            return nil
        }
    }

    var tintColor: UIColor? {
        switch self {
        case .startAndStopImage:
            return .orange
        case .startImage:
            return .green
        default:
            return nil
        }
    }
}
