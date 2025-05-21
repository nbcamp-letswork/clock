//
//  TabBarItemType.swift
//  Clock
//
//  Created by 유현진 on 5/21/25.
//

import Foundation

enum TabBarItemType: CaseIterable {
    case alarm
    case stopwatch
    case timer
}

extension TabBarItemType {
    var title: String {
        switch self {
        case .alarm: "알람"
        case .stopwatch: "스톱워치"
        case .timer: "타이머"
        }
    }
    
    var imageName: String {
        switch self {
        case .alarm: "alarm.fill"
        case .stopwatch: "stopwatch.fill"
        case .timer: "timer"
        }
    }
    
    var index: Int {
        switch self {
        case .alarm: 0
        case .stopwatch: 1
        case .timer: 2
        }
    }
}
