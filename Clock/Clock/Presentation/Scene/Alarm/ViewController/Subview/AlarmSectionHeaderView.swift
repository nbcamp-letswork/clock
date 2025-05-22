import UIKit

final class AlarmSectionHeaderView: UITableViewHeaderFooterView, ReuseIdentifier {
    private let headerLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setAttributes()
        setHierarchy()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(title: String) {
        headerLabel.text = title
    }
}

extension AlarmSectionHeaderView {
    func setAttributes() {
        headerLabel.font = .boldSystemFont(ofSize: 20)
        headerLabel.textColor = .label
    }

    func setHierarchy() {
        contentView.addSubview(headerLabel)
    }

    func setConstraints() {
        headerLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.verticalEdges.trailing.equalToSuperview()
        }
    }
}
