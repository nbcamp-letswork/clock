//
//  StopwatchViewModel.swift
//  Clock
//
//  Created by 유현진 on 5/22/25.
//

import Foundation
import RxSwift
import RxRelay

protocol StopwatchViewModel: StopwatchViewModelInput, StopwatchViewModelOutput {
    var timerDisposable: Disposable? { get set }
    var timer: BehaviorRelay<TimeInterval> { get }
}

protocol StopwatchViewModelInput {
    var startButtonTapped: PublishSubject<Void> { get }
    var stopButtonTapped: PublishSubject<Void> { get }
    var lapRestButtonTapped: PublishSubject<Void> { get }
}

protocol StopwatchViewModelOutput {
    var timerToLabel: Observable<String> { get }
    var leftButtonTitle: Observable<String> { get }
    var isLapButtonEnable: Observable<Bool> { get }
}
