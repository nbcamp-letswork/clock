import UIKit
import SnapKit

enum AlarmDetailCell {
    case group(String),
         repeatDays(String),
         label(String),
         sound(String),
         snooze(Bool)
}

class AlarmDetailCommonCell: UITableViewCell, ReuseIdentifier {
    private let selectedLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setAttributes()
        setHierarchy()
        setConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with text: String) {
        selectedLabel.text = text
    }
}

private extension AlarmDetailCommonCell {
    func setAttributes() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator

        selectedLabel.textAlignment = .right
        selectedLabel.textColor = .secondaryLabel
    }

    func setHierarchy() {
        contentView.addSubview(selectedLabel)
    }

    func setConstraints() {
        selectedLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }
}

final class AlarmDetailGroupCell: AlarmDetailCommonCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textLabel?.text = "그룹"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

final class AlarmDetailRepeatDaysCell: AlarmDetailCommonCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textLabel?.text = "반복"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

final class AlarmDetailLabelCell: UITableViewCell, ReuseIdentifier {
    private let titleLabel = UILabel()
    private let textField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setAttributes()
        setHierarchy()
        setConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with text: String) {
        textField.text = text
    }

    func focusTextField() {
        textField.becomeFirstResponder()
    }

    @objc
    private func textDidChange(_ textField: UITextField) {
        let isEmpty = textField.text?.isEmpty ?? true

        textField.snp.updateConstraints {
            $0.trailing.equalToSuperview().inset(isEmpty ? 20 : 14)
        }
    }
}

private extension AlarmDetailLabelCell {
    func setAttributes() {
        selectionStyle = .none

        titleLabel.text = "레이블"

        textField.placeholder = "알람"
        textField.textColor = .secondaryLabel
        textField.tintColor = .systemOrange
        textField.borderStyle = .none
        textField.textAlignment = .right
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }

    func setHierarchy() {
        [titleLabel, textField]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        textField.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
}

final class AlarmDetailSoundCell: AlarmDetailCommonCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textLabel?.text = "사운드"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

final class AlarmDetailSnoozeCell: UITableViewCell, ReuseIdentifier {
    private let snoozeSwitch = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setAttributes()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with isOn: Bool) {
        snoozeSwitch.isOn = isOn
    }
}

private extension AlarmDetailSnoozeCell {
    func setAttributes() {
        selectionStyle = .none

        textLabel?.text = "다시 알림"

        accessoryView = snoozeSwitch

        snoozeSwitch.isOn = true
    }
}
