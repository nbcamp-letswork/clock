//
//  TimerViewModel.swift
//  Clock
//
//  Created by 이수현 on 5/22/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol TimerViewModel: TimerViewModelInput, TimerViewModelOutput { }

protocol TimerViewModelInput {
    var viewDidLoad: PublishRelay<Void> { get }
}

protocol TimerViewModelOutput {
    var recentTimer: BehaviorRelay<[Timer]> { get }
    var ongoingTimer: BehaviorRelay<[Timer]> { get }
    var error: PublishRelay<Error> { get }
}
