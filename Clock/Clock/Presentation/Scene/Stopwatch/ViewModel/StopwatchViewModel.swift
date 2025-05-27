//
//  StopwatchViewModel.swift
//  Clock
//
//  Created by 유현진 on 5/22/25.
//

import Foundation
import RxSwift
import RxRelay

protocol StopwatchViewModel: StopwatchViewModelInput, StopwatchViewModelOutput { }

protocol StopwatchViewModelInput {
    var startStopButtonTapped: PublishSubject<Void> { get }
    var lapRestButtonTapped: PublishSubject<Void> { get }
    var viewDidLoad: PublishSubject<Void> { get }
    var didEnterBackground: PublishSubject<Void> { get }
}

protocol StopwatchViewModelOutput {
    var lapsToDisplay: Observable<[StopwatchDisplay]> { get }
    var timerToLabel: Observable<String> { get }
    var leftButtonTitle: Observable<String> { get }
    var isLapButtonEnable: Observable<Bool> { get }
    var stopwatchState: Observable<StopwatchState> { get }
}
