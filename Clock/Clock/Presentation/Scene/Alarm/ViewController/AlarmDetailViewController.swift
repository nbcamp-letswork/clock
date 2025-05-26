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

    func setBindings() {
        cancelButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                self.alarmViewModel.updateTime.onNext(datePicker.date)
                self.alarmViewModel.updateLabel.onNext(AlarmLabelDisplay(raw: "레이블 테스트"))
                self.alarmViewModel.updateGroup.onNext("기타")
                self.alarmViewModel.updateRepeatDays.onNext(AlarmRepeatDaysDisplay(raw: [1, 3]))
                self.alarmViewModel.updateSound.onNext(.none)
                self.alarmViewModel.toggleSnoozeSwitch.onNext(false)

                self.alarmViewModel.saveButtonTapped.onNext(())
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            alarmViewModel.groupName,
            alarmViewModel.repeatDays,
            alarmViewModel.label,
            alarmViewModel.sound,
            alarmViewModel.isSnooze
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] groupName, repeatDays, label, sound, isSnooze in
            guard let self = self else { return }

            let items: [AlarmDetailCell] = [
                .group(groupName),
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
