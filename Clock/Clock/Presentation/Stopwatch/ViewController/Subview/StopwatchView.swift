//
//  StopwatchView.swift
//  Clock
//
//  Created by 유현진 on 5/22/25.
//

import UIKit
import SnapKit

final class StopwatchView: UIView {
    private let timeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 88, weight: .thin)
        return label
    }()
    
    let lapResetButton: ClockControlButton = {
        let button = ClockControlButton(type: .lap)
        button.layer.cornerRadius = 43
        return button
    }()
    
    let startStopButton: ClockControlButton = {
        let button = ClockControlButton(type: .startAndStop)
        button.layer.cornerRadius = 43
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setHierarchy()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension StopwatchView {
    func setHierarchy() {
        timeStackView.addArrangedSubview(timeLabel)
        
        [timeStackView, lapResetButton, startStopButton].forEach {
            addSubview($0)
        }
    }
    
    func setConstraints() {
        timeStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide).inset(8)
            make.height.equalToSuperview().dividedBy(2.2)
        }
        
        lapResetButton.snp.makeConstraints { make in
            make.top.equalTo(timeStackView.snp.bottom).offset(-43)
            make.leading.equalToSuperview().inset(16)
            make.size.equalTo(86)
        }
        
        startStopButton.snp.makeConstraints { make in
            make.top.equalTo(timeStackView.snp.bottom).offset(-43)
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(86)
        }
    }
}
