//
//  TimerSoundSelectionView.swift
//  Clock
//
//  Created by 이수현 on 5/27/25.
//

import UIKit

final class TimerSoundSelectionView: UIView {
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(
            AlarmSoundSelectionCell.self,
            forCellReuseIdentifier: AlarmSoundSelectionCell.identifier
        )
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setAttributes()
        setHierarchy()
        setConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension TimerSoundSelectionView {
    func setAttributes() {
        self.backgroundColor = .gray.withAlphaComponent(0.2)
    }

    func setHierarchy() {
        self.addSubview(tableView)
    }

    func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

