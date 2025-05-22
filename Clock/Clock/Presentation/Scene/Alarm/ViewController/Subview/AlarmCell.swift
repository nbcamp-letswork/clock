import UIKit
import RxSwift

final class AlarmCell: UITableViewCell, ReuseIdentifier {
    private let timeStackView = UIStackView()
    private let meridiemLabel = UILabel()
    private let timeLabel = UILabel()
    private let labelAndRepeatDaysLabel = UILabel()
    private let repeatLabel = UILabel()
    let enabledSwitch = UISwitch()

    private(set) var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setAttributes()
        setHierarchy()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(with alarm: AlarmDisplay) {
        meridiemLabel.text = alarm.meridiem
        timeLabel.text = alarm.time
        labelAndRepeatDaysLabel.text = alarm.labelAndRepeatDays
        enabledSwitch.isOn = alarm.isEnabled

        configureLabelColor(with: alarm.isEnabled)
    }

    func configureLabelColor(with isEnabled: Bool) {
        let color: UIColor = isEnabled ? .label : .secondaryLabel
        [meridiemLabel, timeLabel, labelAndRepeatDaysLabel]
            .forEach { $0.textColor = color }
    }
}

private extension AlarmCell {
    func setAttributes() {
        backgroundColor = .clear

        separatorInset = .zero

        timeStackView.axis = .horizontal
        timeStackView.spacing = 2
        timeStackView.alignment = .lastBaseline

        meridiemLabel.font = .systemFont(ofSize: 24, weight: .semibold)

        timeLabel.font = .systemFont(ofSize: 56, weight: .light)

        labelAndRepeatDaysLabel.font = .systemFont(ofSize: 14)
        labelAndRepeatDaysLabel.numberOfLines = 0
    }


    func setHierarchy() {
        [meridiemLabel, timeLabel]
            .forEach { timeStackView.addArrangedSubview($0) }

        [timeStackView, labelAndRepeatDaysLabel, enabledSwitch]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        timeStackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().inset(8)
        }

        enabledSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        labelAndRepeatDaysLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(timeStackView.snp.bottom).offset(8)
            $0.trailing.lessThanOrEqualTo(enabledSwitch.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().inset(16)
        }

        labelAndRepeatDaysLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

}
