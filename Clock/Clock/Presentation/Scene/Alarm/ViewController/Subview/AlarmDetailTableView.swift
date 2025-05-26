import UIKit
import SnapKit

final class AlarmDetailTableView: UITableView {
    private var items = [AlarmDetailCell]()

    init() {
        super.init(frame: .zero, style: .insetGrouped)

        setAttributes()
        setDelegate()
        setDataSource()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(_ items: [AlarmDetailCell]) {
        self.items = items
        self.reloadData()
    }

    private func dequeue<T: UITableViewCell>(_: T.Type, for indexPath: IndexPath) -> T where T: ReuseIdentifier {
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

    func setDelegate() {
        delegate = self
    }

    func setDataSource() {
        dataSource = self
    }
}

extension AlarmDetailTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
}

extension AlarmDetailTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]

        switch item {
        case .group(let name):
            let cell = dequeue(AlarmDetailGroupCell.self, for: indexPath)
            cell.configure(with: name)

            return cell

        case .repeatDays(let text):
            let cell = dequeue(AlarmDetailRepeatDaysCell.self, for: indexPath)
            cell.configure(with: text)

            return cell

        case .label(let text):
            let cell = dequeue(AlarmDetailLabelCell.self, for: indexPath)
            cell.configure(with: text)

            return cell

        case .sound(let text):
            let cell = dequeue(AlarmDetailSoundCell.self, for: indexPath)
            cell.configure(with: text)

            return cell

        case .snooze(let isOn):
            let cell = dequeue(AlarmDetailSnoozeCell.self, for: indexPath)
            cell.configure(with: isOn)

            return cell
        }
    }
}
