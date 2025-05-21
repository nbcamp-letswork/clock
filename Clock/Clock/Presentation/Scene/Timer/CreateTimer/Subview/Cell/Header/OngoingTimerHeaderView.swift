//
//  OngoingTimerHeaderView.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit

final class OngoingTimerHeaderView: UIView {
    private let timerPickerView = TimerPickerView()
    private let cancelButton: ClockControlButton = {
        let button = ClockControlButton(type: .cancel)
        button.layer.cornerRadius = 50
        return button
    }()
    private let startButton: ClockControlButton = {
        let button = ClockControlButton(type: .startAndStop)
        button.layer.cornerRadius = 50
        return button
    }()

    private let settingView = TimerInfoStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setHierarchy()
        setConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension OngoingTimerHeaderView {
    func setHierarchy() {
        [
            timerPickerView,
            cancelButton,
            startButton,
            settingView
        ].forEach { addSubview($0) }
    }

    func setConstraints() {
        timerPickerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.directionalHorizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(timerPickerView.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(12)
            make.size.equalTo(100)
        }

        startButton.snp.makeConstraints { make in
            make.top.equalTo(timerPickerView.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.size.equalTo(100)
        }

        settingView.snp.makeConstraints { make in
            make.top.equalTo(startButton.snp.bottom).offset(24)
            make.directionalHorizontalEdges.equalToSuperview().inset(12)
            make.height.equalTo(100)
            make.bottom.equalToSuperview()
        }
    }
}
