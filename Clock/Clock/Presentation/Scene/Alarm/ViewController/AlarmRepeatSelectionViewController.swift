import UIKit
import SnapKit

final class AlarmRepeatSelectionViewController: UIViewController {
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
        setBindings()
    }
}

extension AlarmRepeatSelectionViewController {
    func setAttributes() {
        view.backgroundColor = .systemBackground

        title = "반복"

        tableView.tintColor = .systemOrange
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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

    func setBindings() {
    }
}

extension AlarmRepeatSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AlarmWeekdayType.allCases.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let weekday = AlarmWeekdayType.allCases[indexPath.row]

        alarmViewModel.toggleWeekday(weekday.rawValue)

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension AlarmRepeatSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weekday = AlarmWeekdayType.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = weekday.description
        cell.accessoryType = alarmViewModel.currentSelectedWeekdays().contains(weekday)
            ? .checkmark
            : .none

        return cell
    }
}
