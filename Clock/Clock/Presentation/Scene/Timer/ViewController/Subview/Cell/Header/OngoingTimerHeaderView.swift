//
//  OngoingTimerHeaderView.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class OngoingTimerHeaderView: UITableViewHeaderFooterView {
    private let timerPickerView = TimerPickerView()
    let disposeBag = DisposeBag()
    let createdTimer = BehaviorRelay<(time: Int, label: String, sound: Sound)?>(value: nil)

    let startButton: ClockControlButton = {
        let button = ClockControlButton(type: .startAndStop)
        button.layer.cornerRadius = 50
        return button
    }()

    private let infoView = TimerInfoStackView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    func setHiddenButton() {
        startButton.isHidden = true

        startButton.snp.updateConstraints { make in
            make.height.equalTo(1)
        }
    }
}

private extension OngoingTimerHeaderView {
    func setAttributes() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .background
        self.backgroundView = backgroundView
    }

    func setHierarchy() {
        [
            timerPickerView,
            startButton,
            infoView
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        timerPickerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.directionalHorizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }

        startButton.snp.makeConstraints { make in
            make.top.equalTo(timerPickerView.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.size.equalTo(100)
        }

        infoView.snp.makeConstraints { make in
            make.top.equalTo(startButton.snp.bottom).offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(12)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().priority(.low)
        }
    }

    func setBindings() {
        Observable.combineLatest(timerPickerView.timeRelay, infoView.timerInfoRelay)
            .map{ ($0, $1.label, $1.sound) }
            .bind(to: createdTimer)
            .disposed(by: disposeBag)

        timerPickerView.timeRelay
            .map{$0 != 0 }
            .bind(to: startButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
