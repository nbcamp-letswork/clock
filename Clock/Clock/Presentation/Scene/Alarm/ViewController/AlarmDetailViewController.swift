import UIKit
import RxSwift
import SnapKit

final class AlarmDetailViewController: UIViewController {
    private let alarmViewModel: AlarmViewModel

    private let disposeBag = DisposeBag()

    private let cancelButton = BarButtonFactory.customButton(with: "취소")
    private let saveButton = BarButtonFactory.customButton(with: "저장")
    private let datePicker = UIDatePicker()
    private let alarmDetailTableView = AlarmDetailTableView()

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

private extension AlarmDetailViewController {
    func setAttributes() {
        view.backgroundColor = .systemGray6

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton

        datePicker.datePickerMode = .time
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.tintColor = .systemOrange
    }

    func setHierarchy() {
        [datePicker, alarmDetailTableView]
            .forEach { view.addSubview($0) }
    }

    func setConstraints() {
        datePicker.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }

        alarmDetailTableView.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }

    func setDelegate() {
        alarmDetailTableView.delegate = self
    }

    func setDataSource() {
        alarmDetailTableView.dataSource = self
    }

    func setBindings() {
        cancelButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                if let labelIndex = alarmDetailTableView.items.firstIndex(where: {
                    if case .label = $0 { return true }
                    else { return false }
                }) {
                    let labelIndexPath = IndexPath(row: labelIndex, section: 0)

                    if let cell = self.alarmDetailTableView.cellForRow(at: labelIndexPath) as? AlarmDetailLabelCell {
                        let text = cell.text() ?? ""
                        self.alarmViewModel.updateLabel.onNext(.init(raw: text))
                    }
                }

                self.alarmViewModel.saveButtonTapped.onNext(())
            })
            .disposed(by: disposeBag)

        datePicker.rx.date
            .bind(to: alarmViewModel.updateTime)
            .disposed(by: disposeBag)

        Observable.combineLatest(
            alarmViewModel.group,
            alarmViewModel.repeatDays,
            alarmViewModel.label,
            alarmViewModel.sound,
            alarmViewModel.isSnooze
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] group, repeatDays, label, sound, isSnooze in
            guard let self = self else { return }

            let items: [AlarmDetailCell] = [
                .group(group.name),
                .repeatDays(repeatDays.detailDescription),
                .label(label.detailDescription),
                .sound(sound.title(for: .alarm)),
                .snooze(isSnooze)
            ]

            self.alarmDetailTableView.configure(items)
        })
        .disposed(by: disposeBag)

        alarmViewModel.saveCompleted
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        alarmViewModel.time
            .bind(to: datePicker.rx.date)
            .disposed(by: disposeBag)
    }
}

extension AlarmDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = alarmDetailTableView.items[indexPath.row]
        switch item {
        case .group:
            let alarmGroupSelectionViewController = AlarmGroupSelectionViewController(
                alarmViewModel: alarmViewModel
            )

            pushOptionViewController(alarmGroupSelectionViewController)
        case .repeatDays:
            let alarmRepeatSelectionViewController = AlarmRepeatSelectionViewController(
                alarmViewModel: alarmViewModel
            )

            pushOptionViewController(alarmRepeatSelectionViewController)
        case .label:
            if let cell = tableView.cellForRow(at: indexPath) as? AlarmDetailLabelCell {
                cell.focusTextField()
            }
        case .sound:
            let alarmSoundSelectionViewController = AlarmSoundSelectionViewController(
                alarmViewModel: alarmViewModel
            )

            pushOptionViewController(alarmSoundSelectionViewController)
        default:
            break
        }
    }

    private func pushOptionViewController(_ viewController: UIViewController) {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.title = "뒤로"
        barButtonItem.tintColor = .systemOrange

        navigationItem.backBarButtonItem = barButtonItem

        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension AlarmDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        alarmDetailTableView.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = alarmDetailTableView.items[indexPath.row]

        switch item {
        case .group(let name):
            let cell = alarmDetailTableView.dequeue(AlarmDetailGroupCell.self, for: indexPath)
            cell.configure(with: name)

            return cell

        case .repeatDays(let text):
            let cell = alarmDetailTableView.dequeue(AlarmDetailRepeatDaysCell.self, for: indexPath)
            cell.configure(with: text)

            return cell

        case .label(let text):
            let cell = alarmDetailTableView.dequeue(AlarmDetailLabelCell.self, for: indexPath)
            cell.configure(with: text)

            return cell

        case .sound(let text):
            let cell = alarmDetailTableView.dequeue(AlarmDetailSoundCell.self, for: indexPath)
            cell.configure(with: text)

            return cell

        case .snooze(let isOn):
            let cell = alarmDetailTableView.dequeue(AlarmDetailSnoozeCell.self, for: indexPath)
            cell.configure(with: isOn)
            cell.snoozeRelay
                .bind(to: alarmViewModel.updateIsSnooze)
                .disposed(by: disposeBag)

            return cell
        }
    }
}
