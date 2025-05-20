//
//  ClockControlButton.swift
//  Clock
//
//  Created by 이수현 on 5/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ClockControlButton: UIButton {
    private let type: ClockControlButtonType
    private let disposeBag = DisposeBag()

    override var isSelected: Bool {
        didSet {
            self.backgroundColor = self.isSelected ? type.selectedBackground : type.backgroundColor
        }
    }

    init(type: ClockControlButtonType) {
        self.type = type
        super.init(frame: .zero)

        setAttributes()
        setBindings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension ClockControlButton {
    func setAttributes() {
        self.setTitle(type.title, for: .normal)
        self.setTitle(type.selectedTitle, for: .selected)
        self.setTitleColor(type.titleColor, for: .normal)
        self.setTitleColor(type.selectedTitleColor, for: .selected)
        self.backgroundColor = type.backgroundColor
    }

    func setBindings() {
        self.rx.tap
            .bind {[weak self]_ in
                guard let self else { return }
                self.isSelected.toggle()
            }.disposed(by: disposeBag)
    }
}
