import UIKit

final class AlarmTableView: UITableView {
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        setAttributes()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension AlarmTableView {
    func setAttributes() {
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        register(AlarmCell.self, forCellReuseIdentifier: AlarmCell.identifier)
        register(AlarmSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: AlarmSectionHeaderView.identifier)
    }
}
