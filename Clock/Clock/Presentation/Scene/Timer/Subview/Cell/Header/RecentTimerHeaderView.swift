//
//  RecentTimerHeaderView.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit

final class RecentTimerHeaderView: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)

        setAttributes()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension RecentTimerHeaderView {
    func setAttributes() {
        self.text = "최근 항목"
        self.textColor = .white
        self.font = .systemFont(ofSize: 24, weight: .bold)
    }
}
