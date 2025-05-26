import UIKit

final class AlarmGroupSelectionCell: UITableViewCell, ReuseIdentifier {
    private let checkmarkView = UIImageView()

    private let titleLabel = UILabel()

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

    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        checkmarkView.isHidden = !isSelected
    }
}

extension AlarmGroupSelectionCell {
    func setAttributes() {
        checkmarkView.image = UIImage(systemName: "checkmark")
        checkmarkView.tintColor = .systemOrange
        checkmarkView.isHidden = true
    }

    func setHierarchy() {
        [checkmarkView, titleLabel]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        checkmarkView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        checkmarkView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        titleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.leading.equalTo(checkmarkView.snp.trailing).offset(20)
            $0.trailing.centerY.equalToSuperview()
        }
    }
}
