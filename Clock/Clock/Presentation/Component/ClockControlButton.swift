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
            self.backgroundColor = self.isSelected ? type.selectedBackgroundColor : type.backgroundColor
        }
    }

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? type.backgroundColor : type.backgroundColor?.withAlphaComponent(0.1)
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

        self.backgroundColor = type.backgroundColor
        self.isHighlighted = false
        switch type {
        case .startImage, .startAndStopImage:
            self.setImage(type.image, for: .normal)
            self.setImage(type.selectedImage, for: .selected)
            self.contentVerticalAlignment = type == .startImage ? .center : .fill
            self.contentHorizontalAlignment = type == .startImage ? .center : .fill
            self.tintColor = type.tintColor
        default:
            self.setTitle(type.title, for: .normal)
            self.setTitle(type.title, for: .disabled)
            self.setTitle(type.selectedTitle, for: .selected)
            self.setTitleColor(type.titleColor, for: .normal)
            self.setTitleColor(type.disabledTitleColor, for: .disabled)
            self.setTitleColor(type.selectedTitleColor, for: .selected)
        }
    }

    func setBindings() {
        self.rx.tap
            .bind {[weak self]_ in
                guard let self, type != .startImage else { return }
                self.isSelected.toggle()
            }.disposed(by: disposeBag)
    }
}
