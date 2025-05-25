import UIKit
import RxSwift
import RxCocoa

final class AlarmViewController: UIViewController {
    private let alarmViewModel: AlarmViewModel

    private let disposeBag = DisposeBag()

    private let editButton = BarButtonFactory.customButton(with: "편집")
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
        ) { [weak self] tableView, indexPath, alarm in
            guard let self,
                  let cell = tableView.dequeueReusableCell(
                    withIdentifier: AlarmCell.identifier,
                    for: indexPath
                  ) as? AlarmCell
            else {
                return UITableViewCell()
            }

            cell.configure(with: alarm)
            cell.configureTopSeparator(with: indexPath.row == 0)
            cell.configureEditing(self.alarmViewModel.currentIsEditing(), animated: false)
            cell.enabledSwitch.rx.isOn
                .skip(1)
                .distinctUntilChanged()
                .bind(with: self) { owner, isOn in
                    cell.configureLabelColor(with: isOn)

                    if let indexPath = owner.alarmTableView.indexPath(for: cell),
                       case let .group(group) = owner.dataSource.snapshot().sectionIdentifiers[indexPath.section] {
                        let groupID = group.id
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
            .bind(to: alarmViewModel.editButtonTapped)
            .disposed(by: disposeBag)

        plusButton.rx.tap
            .bind(to: alarmViewModel.plusButtonTapped)
            .disposed(by: disposeBag)

        alarmViewModel.showAlarmDetail
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                let alarmDetailViewController = AlarmDetailViewController(alarmViewModel: owner.alarmViewModel)
                alarmDetailViewController.title = "알람 추가"

                let navigationController = UINavigationController(rootViewController: alarmDetailViewController)
                owner.present(navigationController, animated: true)

                owner.alarmViewModel.updateIsSwiping(false)
                owner.alarmViewModel.updateIsEditing(false)
            }
            .disposed(by: disposeBag)

        alarmViewModel.alarmGroups
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] groups in
                self?.applySnapshot(with: groups)
            })
            .disposed(by: disposeBag)

        alarmViewModel.isEditing
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isEditing in
                guard let self else { return }

                self.editButton.title = isEditing ? "완료" : "편집"

                self.alarmTableView.setEditing(isEditing, animated: true)

                self.alarmTableView.visibleCells
                    .forEach { cell in
                        (cell as? AlarmCell)?.configureEditing(isEditing)
                    }
            })
            .disposed(by: disposeBag)

        alarmViewModel.isSwiping
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isSwiping in
                guard let self else { return }

                if !isSwiping {
                    self.alarmTableView.setEditing(false, animated: true)
                }
            })
            .disposed(by: disposeBag)

        alarmTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}

extension AlarmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: AlarmSectionHeaderView.identifier
        ) as? AlarmSectionHeaderView else {
            return nil
        }

        let sectionIdentifier = dataSource.snapshot().sectionIdentifiers[section]
        if case let .group(group) = sectionIdentifier {
            headerView.configure(title: group.name)
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completionHandler in
            guard let self else { return }

            let snapshot = self.dataSource.snapshot()
            let section = snapshot.sectionIdentifiers[indexPath.section]

            guard case let .group(group) = section else {
                completionHandler(false)

                return
            }

            let items = snapshot.itemIdentifiers(inSection: section)
            let alarm = items[indexPath.row]

            self.alarmViewModel.deleteAlarm.onNext((group.id, alarm.id))

            completionHandler(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.alarmViewModel.updateIsSwiping(true)
        }

        self.editButton.title = "완료"

        if let cell = tableView.cellForRow(at: indexPath) as? AlarmCell {
            cell.configureSwiping(true)
        }
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        DispatchQueue.main.async { [weak self] in
            self?.alarmViewModel.updateIsSwiping(false)
        }

        self.editButton.title = "편집"

        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }

        for indexPath in indexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? AlarmCell {
                cell.configureSwiping(false)
            }
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let alarmCell = cell as? AlarmCell {
            alarmCell.configureEditing(alarmViewModel.currentIsEditing(), animated: false)
        }
    }
}
