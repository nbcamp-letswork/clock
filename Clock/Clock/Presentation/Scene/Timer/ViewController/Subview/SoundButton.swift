//
//  SoundButton.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit
import RxSwift
import RxRelay

final class SoundButton: UIButton {
    private let disposeBag = DisposeBag()
    let soundRelay = BehaviorRelay<SoundDisplay>(value: .bell)

    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "타이머 종료 시"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private let soundLabel: UILabel = {
        let label = UILabel()
        label.text = "전파 탐지기"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .init(systemName: "chevron.right")
        imageView.tintColor = .systemGray
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
}

private extension SoundButton {
    func setAttributes() {
        self.clipsToBounds = true
        self.backgroundColor = .gray.withAlphaComponent(0.2)
    }

    func setHierarchy() {
        [
            textLabel,
            soundLabel,
            chevronImageView,
        ].forEach { self.addSubview($0) }
    }

    func setConstraints() {
        textLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
        }

        soundLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-4)
            make.leading.greaterThanOrEqualTo(textLabel.snp.trailing).offset(16)
        }

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
            make.height.equalTo(12)
            make.width.equalTo(10)
        }
    }

    func setBindings() {
        soundRelay
            .map{$0.title(for: .timer)}
            .bind(to: soundLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
