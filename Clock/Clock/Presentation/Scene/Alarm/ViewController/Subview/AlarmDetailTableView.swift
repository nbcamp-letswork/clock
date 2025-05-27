import UIKit
import SnapKit

final class AlarmDetailTableView: UITableView {
    private(set) var items = [AlarmDetailCell]()

    init() {
        super.init(frame: .zero, style: .insetGrouped)

        setAttributes()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(_ items: [AlarmDetailCell]) {
        self.items = items
        self.reloadData()
    }

    func dequeue<T: UITableViewCell>(_: T.Type, for indexPath: IndexPath) -> T where T: ReuseIdentifier {
        dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }
}

private extension AlarmDetailTableView {
    func setAttributes() {
        sectionHeaderHeight = 0
        isScrollEnabled = false

        register(AlarmDetailGroupCell.self, forCellReuseIdentifier: AlarmDetailGroupCell.identifier)
        register(AlarmDetailRepeatDaysCell.self, forCellReuseIdentifier: AlarmDetailRepeatDaysCell.identifier)
        register(AlarmDetailLabelCell.self, forCellReuseIdentifier: AlarmDetailLabelCell.identifier)
        register(AlarmDetailSoundCell.self, forCellReuseIdentifier: AlarmDetailSoundCell.identifier)
        register(AlarmDetailSnoozeCell.self, forCellReuseIdentifier: AlarmDetailSnoozeCell.identifier)
    }
}
