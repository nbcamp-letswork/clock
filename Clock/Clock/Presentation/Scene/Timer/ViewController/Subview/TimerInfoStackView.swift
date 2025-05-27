//
//  TimerInfoStackView.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TimerInfoStackView: UIStackView {
    private let disposeBag = DisposeBag()
    let timerInfoRelay = BehaviorRelay<(label: String, sound: SoundDisplay)>(value: ("" ,.none))

    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .gray.withAlphaComponent(0.2)
        stackView.axis = .horizontal
        stackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 8
        return stackView
    }()

    private let labelLabel: UILabel = {
        let label = UILabel()
        label.text = "레이블"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.sizeToFit()
        return label
    }()

    private let labelTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "타이머"
        textField.font = .systemFont(ofSize: 16)
        textField.textAlignment = .right
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        return textField
    }()

    let soundButton = SoundButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setAttributes()
        setHierarchy()
        setBindings()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }

    func configure(sound: SoundDisplay) {
        soundButton.soundRelay.accept(sound)
    }
}

private extension TimerInfoStackView {
    func setAttributes() {
        self.backgroundColor = .background
        self.axis = .vertical
        self.spacing = 1
        self.distribution = .fillEqually
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
    }

    func setHierarchy() {
        [
            labelLabel,
            labelTextField
        ].forEach { labelStackView.addArrangedSubview($0) }

        [
            labelStackView,
            soundButton
        ].forEach { self.addArrangedSubview($0) }
    }

    func setBindings() {
        Observable.combineLatest(labelTextField.rx.text.orEmpty, soundButton.soundRelay)
            .bind { [weak self] label, sound in
                self?.timerInfoRelay.accept((label, sound))
            }
            .disposed(by: disposeBag)
    }
}
