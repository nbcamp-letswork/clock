//
//  TimerView.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit

final class TimerView: UIView {
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.keyboardDismissMode = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.register(RecentTimerCell.self, forCellReuseIdentifier: RecentTimerCell.identifier)
        tableView.register(OngoingTimerCell.self, forCellReuseIdentifier: OngoingTimerCell.identifier)
        return tableView
    }()

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

private extension TimerView {
    func setHierarchy() {
        self.addSubview(tableView)
    }

    func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

