//
//  TimerViewModel.swift
//  Clock
//
//  Created by 이수현 on 5/22/25.
//

import Foundation
import RxSwift
import RxRelay

protocol TimerViewModel:
    TimerViewModelInput, TimerViewModelOutput,
    TimerSoundSelectionViewModel {}

protocol TimerViewModelInput {
    var viewDidLoad: PublishRelay<Void> { get }
    var saveTimers: PublishRelay<Void> { get }
    var createTimer: PublishRelay<(time: Int, label: String, sound: SoundDisplay)> { get }
    var toggleOrAddTimer: PublishRelay<UUID> { get }
    var deleteTimer: PublishRelay<IndexPath> { get }
}

protocol TimerViewModelOutput {
    var recentTimer: BehaviorRelay<[TimerDisplay]> { get }
    var ongoingTimer: BehaviorRelay<[TimerDisplay]> { get }
    var error: PublishRelay<Error> { get }
}
