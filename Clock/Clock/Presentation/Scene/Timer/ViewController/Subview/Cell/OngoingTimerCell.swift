//
//  OngoingTimerCell.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit

final class OngoingTimerCell: UITableViewCell, ReuseIdentifier {
    private let currentTimerLabel: UILabel = {
        let label = UILabel()
        label.text = "10:00"
        label.textColor = .white
        label.font = .systemFont(ofSize: 60)
        return label
    }()

    private let labelLabel: UILabel = {
        let label = UILabel()
        label.text = "10분"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    let controlButton: ClockControlButton = {
        let button = ClockControlButton(type: .startAndStopImage)
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAttributes()
        setHierarchy()
        setConstraints()
    }
    
    required
    init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(timer: TimerDisplay) {
        currentTimerLabel.text = timer.currentTime
        labelLabel.text = timer.label
    }
}

private extension OngoingTimerCell {
    func setAttributes() {
        self.backgroundColor = .background
        self.selectionStyle = .none
    }

    func setHierarchy() {
        [
            currentTimerLabel,
            labelLabel,
            controlButton
        ].forEach { self.contentView.addSubview($0) }
    }

    func setConstraints() {
        currentTimerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(12)
        }

        labelLabel.snp.makeConstraints { make in
            make.top.equalTo(currentTimerLabel.snp.bottom).offset(12)
            make.leading.equalTo(currentTimerLabel)
            make.bottom.equalToSuperview().inset(12)
        }

        controlButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(60)
        }
    }
}
