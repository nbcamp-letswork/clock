//
//  LapCollectionViewCell.swift
//  Clock
//
//  Created by 유현진 on 5/25/25.
//

import UIKit
import SnapKit

final class LapTableViewCell: UITableViewCell, ReuseIdentifier {
    private let lapNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAttributes()
        setHierarchy()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(number: Int, time: String) {
        lapNumberLabel.text = "랩 \(number)"
        timeLabel.text = time
    }
}

private extension LapTableViewCell {
    func setAttributes() {
        backgroundColor = .systemBackground
        selectionStyle = .none
    }
    
    func setHierarchy() {
        [lapNumberLabel, timeLabel].forEach {
            addSubview($0)
        }
    }
    
    func setConstraints() {
        lapNumberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }
}
