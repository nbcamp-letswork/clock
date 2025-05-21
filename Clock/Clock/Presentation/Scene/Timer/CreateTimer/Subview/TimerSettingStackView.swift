//
//  TimerSettingStackView.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit

final class TimerSettingStackView: UIStackView {
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
        return textField
    }()

    private let soundStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .gray.withAlphaComponent(0.2)
        stackView.axis = .horizontal
        stackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    private let soundLabel: UILabel = {
        let label = UILabel()
        label.text = "타이머 종료 시"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.sizeToFit()
        return label
    }()

    private let soundButton: UIButton = {
        let title = "전파 탐지기"
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 16)
        ]))
        configuration.imagePadding = 4
        configuration.contentInsets = .zero
        configuration.image = .init(systemName: "chevron.right")
        configuration.imagePlacement = .trailing

        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 12)
        configuration.preferredSymbolConfigurationForImage = imageConfiguration

        let button = UIButton()
        button.tintColor = .systemGray
        button.configuration = configuration

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setAttributes()
        setHierarchy()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError()
    }
}

private extension TimerSettingStackView {
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
            soundLabel,
            soundButton
        ].forEach { soundStackView.addArrangedSubview($0) }

        [
            labelStackView,
            soundStackView
        ].forEach { self.addArrangedSubview($0) }
    }
}

