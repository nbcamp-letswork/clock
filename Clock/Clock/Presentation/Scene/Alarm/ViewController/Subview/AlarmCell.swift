import UIKit
import SnapKit
import RxSwift

final class AlarmCell: UITableViewCell, ReuseIdentifier {
    private let topSeparatorView = UIView()
    private let timeStackView = UIStackView()
    private let meridiemLabel = UILabel()
    private let timeLabel = UILabel()
    private let labelAndRepeatDaysLabel = UILabel()
    private let repeatLabel = UILabel()
    private let accessoryContainerView = UIView()
    let enabledSwitch = UISwitch()
    private let disclosureImageView = UIImageView()
    private let separatorView = UIView()

    private(set) var disposeBag = DisposeBag()

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

    override func prepareForReuse() {
        super.prepareForReuse()

        disposeBag = DisposeBag()

        configureSwiping(false, animated: false)
    }

    func configure(with alarm: AlarmDisplay) {
        meridiemLabel.text = alarm.meridiem
        timeLabel.text = alarm.time
        labelAndRepeatDaysLabel.text = alarm.labelAndRepeatDays
        enabledSwitch.isOn = alarm.isEnabled

        configureLabelColor(with: alarm.isEnabled)
    }

    func configureTopSeparator(with isFirstCell: Bool) {
        topSeparatorView.isHidden = !isFirstCell
    }

    func configureLabelColor(with isEnabled: Bool) {
        let color: UIColor = isEnabled ? .label : .secondaryLabel
        [meridiemLabel, timeLabel, labelAndRepeatDaysLabel]
            .forEach { $0.textColor = color }
    }

    func configureSwiping(_ isSwiping: Bool, animated: Bool = true) {
        let animations = {
            self.enabledSwitch.transform = isSwiping ? CGAffineTransform(translationX: -20, y: 0) : .identity
            self.enabledSwitch.alpha = isSwiping ? 0 : 1
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: animations)
        } else {
            animations()
        }
    }
}

private extension AlarmCell {
    func setAttributes() {
        backgroundColor = .clear

        topSeparatorView.backgroundColor = .separator
        topSeparatorView.isHidden = true

        timeStackView.axis = .horizontal
        timeStackView.spacing = 2
        timeStackView.alignment = .bottom

        meridiemLabel.font = .systemFont(ofSize: 24, weight: .semibold)

        timeLabel.font = .systemFont(ofSize: 56, weight: .light)

        labelAndRepeatDaysLabel.font = .systemFont(ofSize: 14)
        labelAndRepeatDaysLabel.numberOfLines = 0
        labelAndRepeatDaysLabel.lineBreakMode = .byClipping

        let config = UIImage.SymbolConfiguration(weight: .bold)
        disclosureImageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        disclosureImageView.tintColor = .tertiaryLabel
        disclosureImageView.isHidden = true

        separatorView.backgroundColor = .separator
    }

    func setHierarchy() {
        [meridiemLabel, timeLabel]
            .forEach { timeStackView.addArrangedSubview($0) }

        [enabledSwitch, disclosureImageView]
            .forEach { accessoryContainerView.addSubview($0) }

        [topSeparatorView, timeStackView, labelAndRepeatDaysLabel, accessoryContainerView, separatorView]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        topSeparatorView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(0.7)
        }

        timeStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(8).priority(.low)
            $0.height.equalTo(50)
        }

        accessoryContainerView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(64)
        }

        enabledSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(timeStackView.snp.bottom)
        }

        disclosureImageView.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }

        labelAndRepeatDaysLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(timeStackView.snp.bottom).offset(8).priority(.low)
            $0.trailing.equalTo(accessoryContainerView.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().inset(16).priority(.low)
        }

        separatorView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.7)
        }
    }

}
