import UIKit
import SnapKit

final class AlarmGroupSelectionViewController: UIViewController {
    private let alarmViewModel: AlarmViewModel

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(alarmViewModel: AlarmViewModel) {
        self.alarmViewModel = alarmViewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setAttributes()
        setHierarchy()
        setConstraints()
        setDelegate()
        setDataSource()
    }
}

extension AlarmGroupSelectionViewController {
    func setAttributes() {
        title = "그룹"

        tableView.tintColor = .systemOrange
        tableView.register(AlarmGroupTypingCell.self, forCellReuseIdentifier: AlarmGroupTypingCell.identifier)
        tableView.register(AlarmGroupSelectionCell.self, forCellReuseIdentifier: AlarmGroupSelectionCell.identifier)
    }

    func setHierarchy() {
        view.addSubview(tableView)
    }

    func setConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setDelegate() {
        tableView.delegate = self
    }

    func setDataSource() {
        tableView.dataSource = self
    }
}

extension AlarmGroupSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = AlarmGroupSection(rawValue: indexPath.section) else { return }
        switch section {
        case .typing:
            if let cell = tableView.cellForRow(at: indexPath) as? AlarmGroupTypingCell {
                cell.focusTextField()
            }
        case .groups:
            let selected = alarmViewModel.currentGroups()[indexPath.row]

            alarmViewModel.updateSelectedGroup(selected)

            tableView.reloadData()

            guard let cell = tableView.cellForRow(at: indexPath) else { return }

            cell.contentView.backgroundColor = UIColor.systemGray4

            UIView.animate(withDuration: 0.3) {
                cell.contentView.backgroundColor = UIColor.systemGray5
            }

            let typingIndexPath = IndexPath(row: 0, section: AlarmGroupSection.typing.rawValue)
            if let typingCell = tableView.cellForRow(at: typingIndexPath) as? AlarmGroupTypingCell {
                if selected.name != "기타" {
                    typingCell.configure(with: selected.name)
                } else {
                    typingCell.configure(with: nil)
                }
            }
        }
    }
}

extension AlarmGroupSelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        AlarmGroupSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = AlarmGroupSection(rawValue: section) else { return 0 }
        switch section {
        case .typing:
            return 1
        case .groups:
            return max(alarmViewModel.currentGroups().count, 1)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = AlarmGroupSection(rawValue: section) else { return nil }
        switch section {
        case .typing: return "직접 입력"
        case .groups: return "선택"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = AlarmGroupSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {
        case .typing:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: AlarmGroupTypingCell.identifier,
                for: indexPath
            ) as? AlarmGroupTypingCell else {
                return AlarmGroupTypingCell()
            }

            cell.labelRelay
                .subscribe(onNext: { [weak self] text in
                    self?.handleTypingChanged(text)
                })
                .disposed(by: cell.disposeBag)

            let selected = alarmViewModel.currentSelectedGroup()

            if selected.name != "기타" {
                cell.configure(with: selected.name)
            } else {
                cell.configure(with: nil)
            }

            return cell

        case .groups:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: AlarmGroupSelectionCell.identifier,
                for: indexPath
            ) as? AlarmGroupSelectionCell else {
                return AlarmGroupSelectionCell()
            }

            let groups = alarmViewModel.currentGroups()

            if groups.isEmpty {
                cell.configure(with: "기타", isSelected: true)
            } else {
                let group = groups[indexPath.row]

                cell.configure(with: group.name, isSelected: alarmViewModel.currentSelectedGroup().name == group.name)
            }

            return cell
        }
    }

    func handleTypingChanged(_ name: String) {
        if name.isEmpty {
            if let defaultGroup = alarmViewModel.currentGroups().first(where: { $0.name == "기타" }) {
                alarmViewModel.updateSelectedGroup(defaultGroup)
            } else {
                alarmViewModel.updateTypingGroup("")
            }
            tableView.reloadSections(IndexSet(integer: AlarmGroupSection.groups.rawValue), with: .none)
            return
        }

        let matchedGroup = alarmViewModel.currentGroups().first { $0.name == name }

        if let group = matchedGroup {
            alarmViewModel.updateSelectedGroup(group)
        } else {
            alarmViewModel.updateTypingGroup(name)
        }

        tableView.reloadSections(IndexSet(integer: AlarmGroupSection.groups.rawValue), with: .none)
    }
}
