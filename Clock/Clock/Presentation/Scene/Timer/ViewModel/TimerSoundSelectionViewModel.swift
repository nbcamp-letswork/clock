//
//  TimerSoundSelectionViewModel.swift
//  Clock
//
//  Created by 이수현 on 5/27/25.
//

import RxSwift
import RxRelay

protocol TimerSoundSelectionViewModel: TimerSoundSelectionViewModelInput, TimerSoundSelectionViewModelOutput {}

protocol TimerSoundSelectionViewModelInput {
    var updatedSound: PublishRelay<SoundDisplay> { get }
}

protocol TimerSoundSelectionViewModelOutput {
    var currentSound: BehaviorRelay<SoundDisplay> { get }
}
