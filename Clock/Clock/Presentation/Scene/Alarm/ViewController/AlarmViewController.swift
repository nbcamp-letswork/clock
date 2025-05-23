import UIKit
import RxSwift
import RxCocoa

final class AlarmViewController: UIViewController {
    private let alarmViewModel: AlarmViewModel

    private let disposeBag = DisposeBag()

    private let editButton = BarButtonFactory.editButton()
    private let plusButton = BarButtonFactory.plusButton()
    private let alarmTableView = AlarmTableView(frame: .zero, style: .grouped)
    private var dataSource: UITableViewDiffableDataSource<AlarmSection, AlarmDisplay>!

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
        setDataSource()
        setBindings()

        alarmViewModel.viewDidLoad.onNext(())
    }

    private func applySnapshot(with groups: [AlarmGroupDisplay]) {
        var snapshot = NSDiffableDataSourceSnapshot<AlarmSection, AlarmDisplay>()

        for group in groups {
            let section = AlarmSection.group(group)
            snapshot.appendSections([section])
            snapshot.appendItems(group.alarms, toSection: section)
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

private extension AlarmViewController {
    func setAttributes() {
        navigationItem.leftBarButtonItem = editButton
        navigationItem.rightBarButtonItem = plusButton

        title = "알람"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func setHierarchy() {
        view.addSubview(alarmTableView)
    }

    func setConstraints() {
        alarmTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setDataSource() {
        dataSource = UITableViewDiffableDataSource<AlarmSection, AlarmDisplay>(
            tableView: alarmTableView
        ) { tableView, indexPath, alarm in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: AlarmCell.identifier,
                for: indexPath
            ) as? AlarmCell else { return UITableViewCell() }

            cell.configure(with: alarm)
            cell.configureTopSeparator(with: indexPath.row == 0)
            cell.enabledSwitch.rx.isOn
                .skip(1)
                .distinctUntilChanged()
                .bind(with: self) { owner, isOn in
                    cell.configureLabelColor(with: isOn)

                    if let indexPath = owner.alarmTableView.indexPath(for: cell),
                       case let .group(groupDisplay) = owner.dataSource.snapshot().sectionIdentifiers[indexPath.section] {
                        let groupID = groupDisplay.id
                        let alarmID = alarm.id

                        owner.alarmViewModel.toggleSwitch.onNext((groupID, alarmID, isOn))
                    }
                }
                .disposed(by: cell.disposeBag)

            return cell
        }

        dataSource.defaultRowAnimation = .fade
    }

    func setBindings() {
        editButton.rx.tap
            .bind {}
            .disposed(by: disposeBag)

        plusButton.rx.tap
            .bind {}
            .disposed(by: disposeBag)

        alarmViewModel.alarmGroups
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] groups in
                self?.applySnapshot(with: groups)
            })
            .disposed(by: disposeBag)

        alarmTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}

extension AlarmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AlarmSectionHeaderView.identifier) as? AlarmSectionHeaderView else {
            return nil
        }

        let sectionIdentifier = dataSource.snapshot().sectionIdentifiers[section]
        if case let .group(groupDisplay) = sectionIdentifier {
            headerView.configure(title: groupDisplay.name)
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
