import UIKit
import SnapKit

final class AlarmSoundSelectionViewController: UIViewController {
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

extension AlarmSoundSelectionViewController {
    func setAttributes() {
        title = "사운드"

        tableView.tintColor = .systemOrange
        tableView.register(AlarmSoundSelectionCell.self, forCellReuseIdentifier: AlarmSoundSelectionCell.identifier)
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

extension AlarmSoundSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected: SoundDisplay

        switch AlarmSoundSection(rawValue: indexPath.section)! {
        case .sound:
            selected = SoundDisplay.allCases[indexPath.row]
        case .none:
            selected = .none
        }

        alarmViewModel.updateSelectedSound(selected)

        tableView.reloadData()

        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        cell.contentView.backgroundColor = UIColor.systemGray4

        UIView.animate(withDuration: 0.3) {
            cell.contentView.backgroundColor = UIColor.systemGray5
        }
    }
}

extension AlarmSoundSelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        AlarmSoundSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = AlarmSoundSection(rawValue: section) else { return 0 }
        switch section {
        case .sound:
            return SoundDisplay.allCases.count - 1
        case .none:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = AlarmSoundSection(rawValue: section) else { return nil }
        switch section {
        case .sound: return "벨소리"
        case .none: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AlarmSoundSelectionCell.identifier,
            for: indexPath
        ) as? AlarmSoundSelectionCell else {
            return AlarmSoundSelectionCell()
        }

        let sound: SoundDisplay

        switch AlarmSoundSection(rawValue: indexPath.section)! {
        case .sound:
            sound = SoundDisplay.allCases[indexPath.row]
        case .none:
            sound = .none
        }

        cell.configure(
            with: sound.title(for: .alarm),
            isSelected: alarmViewModel.currentSelectedSound() == sound
        )

        return cell
    }
}
