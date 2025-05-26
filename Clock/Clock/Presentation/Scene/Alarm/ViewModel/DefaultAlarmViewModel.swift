import Foundation
import RxSwift
import RxRelay

final class DefaultAlarmViewModel: AlarmViewModel {
    private let fetchAlarmUseCase: FetchableAlarmUseCase
    private let createAlarmUseCase: CreatableAlarmUseCase
    private let deleteAlarmUseCase: DeletableAlarmUseCase
    private let deleteAlarmGroupUseCase: DeletableAlarmGroupUseCase

    private let mapper = AlarmMapper()

    private let disposeBag = DisposeBag()

    private let viewDidLoadSubject = PublishSubject<Void>()
    private let toggleSwitchSubject = PublishSubject<(groupID: UUID, alarmID: UUID, isOn: Bool)>()
    private let editButtonTappedSubject = PublishSubject<Void>()
    private let deleteAlarmSubject = PublishSubject<(groupID: UUID, alarmID: UUID)>()
    private let plusButtonTappedSubject = PublishSubject<Void>()

    private let alarmGroupsRelay = BehaviorRelay<[AlarmGroupDisplay]>(value: [])
    private let isEditingRelay = BehaviorRelay<Bool>(value: false)
    private let isSwipingRelay = BehaviorRelay<Bool>(value: false)
    private let showAlarmDetailSubject = PublishSubject<(AlarmDisplay, AlarmGroupDisplay)>()

    private let saveButtonTappedSubject = PublishSubject<Void>()
    private let updateTimeSubject = PublishSubject<Date>()
    private let updateLabelSubject = PublishSubject<AlarmLabelDisplay>()
    private let updateIsSnoozeSubject = PublishSubject<Bool>()

    private let saveCompletedSubject = PublishSubject<Void>()
    private let groupRelay = BehaviorRelay<AlarmGroupDisplay>(value: .init())
    private let alarmRelay = BehaviorRelay<AlarmDisplay>(value: .init())
    private let timeRelay = BehaviorRelay<Date>(value: Date())
    private let repeatDaysRelay = BehaviorRelay<AlarmRepeatDaysDisplay>(value: .init(raw: []))
    private let labelRelay = BehaviorRelay<AlarmLabelDisplay>(value: .init(raw: ""))
    private let soundRelay = BehaviorRelay<SoundDisplay>(value: .bell)
    private let isSnoozeRelay = BehaviorRelay<Bool>(value: false)

    init(
        fetchAlarmUseCase: FetchableAlarmUseCase,
        createAlarmUseCase: CreatableAlarmUseCase,
        deleteAlarmUseCase: DeletableAlarmUseCase,
        deleteAlarmGroupUseCase: DeletableAlarmGroupUseCase

    ) {
        self.fetchAlarmUseCase = fetchAlarmUseCase
        self.createAlarmUseCase = createAlarmUseCase
        self.deleteAlarmUseCase = deleteAlarmUseCase
        self.deleteAlarmGroupUseCase = deleteAlarmGroupUseCase

        bindAlarmList()
        bindAlarmDetail()
    }
}

extension DefaultAlarmViewModel {
    var viewDidLoad: AnyObserver<Void> { viewDidLoadSubject.asObserver() }
    var toggleSwitch: AnyObserver<(groupID: UUID, alarmID: UUID, isOn: Bool)> { toggleSwitchSubject.asObserver() }
    var editButtonTapped: AnyObserver<Void> { editButtonTappedSubject.asObserver() }
    var deleteAlarm: AnyObserver<(groupID: UUID, alarmID: UUID)> { deleteAlarmSubject.asObserver() }
    var plusButtonTapped: AnyObserver<Void> { plusButtonTappedSubject.asObserver() }

    var alarmGroups: Observable<[AlarmGroupDisplay]> { alarmGroupsRelay.asObservable() }
    var isEditing: Observable<Bool> { isEditingRelay.asObservable() }
    var isSwiping: Observable<Bool> { isSwipingRelay.asObservable() }
    var showAlarmDetail: Observable<(AlarmDisplay, AlarmGroupDisplay)> { showAlarmDetailSubject.asObservable() }

    private func bindAlarmList() {
        viewDidLoadSubject
            .flatMapLatest { [weak self] _ -> Observable<[AlarmGroupDisplay]> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    Task {
                        do {
                            let domainGroups = try await self.fetchAlarmUseCase.execute()
                            let displayGroups = domainGroups.map { self.mapper.mapToAlarmGroupDisplay($0) }

                            observer.onNext(displayGroups)
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
                }
            }
            .subscribe(onNext: { [weak self] groups in
                self?.alarmGroupsRelay.accept(groups)
            })
            .disposed(by: disposeBag)

        toggleSwitchSubject
            .subscribe(onNext: { [weak self] groupID, alarmID, isOn in
                self?.updateAlarmEnabled(groupID: groupID, alarmID: alarmID, isEnabled: isOn)
            })
            .disposed(by: disposeBag)

        editButtonTappedSubject
            .withLatestFrom(Observable.combineLatest(isEditingRelay, isSwipingRelay))
            .subscribe(onNext: { [weak self] isEditing, isSwiping in
                guard let self = self else { return }

                isSwiping
                    ? self.isSwipingRelay.accept(false)
                    : self.isEditingRelay.accept(!isEditing)
            })
            .disposed(by: disposeBag)

        deleteAlarmSubject
            .subscribe(onNext: { [weak self] groupID, alarmID in
                Task {
                    await self?.deleteAlarm(groupID: groupID, alarmID: alarmID)
                }
            })
            .disposed(by: disposeBag)

        plusButtonTappedSubject
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                let alarm = self.makeDefaultAlarmDisplay()
                let group = self.makeDefaultAlarmGroupDisplay()

                self.selectEditingAlarm(alarm, group)
                self.showAlarmDetailSubject.onNext((alarm, group))
            })
            .disposed(by: disposeBag)
    }

    private func groupIndex(for groupID: UUID) -> Int? {
        alarmGroupsRelay.value.firstIndex(where: { $0.id == groupID })
    }

    private func alarmIndex(for alarmID: UUID, in groupIndex: Int) -> Int? {
        alarmGroupsRelay.value[groupIndex].alarms.firstIndex(where: { $0.id == alarmID })
    }

    private func updateAlarmEnabled(groupID: UUID, alarmID: UUID, isEnabled: Bool) {
        guard let groupIndex = groupIndex(for: groupID),
              let alarmIndex = alarmIndex(for: alarmID, in: groupIndex)
        else {
            return
        }

        var groups = alarmGroupsRelay.value
        groups[groupIndex].alarms[alarmIndex].isEnabled = isEnabled

        alarmGroupsRelay.accept(groups)
    }

    private func deleteAlarm(groupID: UUID, alarmID: UUID) async {
        do {
            try await deleteAlarmUseCase.execute(alarmID)

            guard let groupIndex = groupIndex(for: groupID),
                  let alarmIndex = alarmIndex(for: alarmID, in: groupIndex)
            else {
                return
            }

            var groups = alarmGroupsRelay.value
            groups[groupIndex].alarms.remove(at: alarmIndex)

            alarmGroupsRelay.accept(groups)
        } catch {}
    }

    private func makeDefaultAlarmGroupDisplay() -> AlarmGroupDisplay {
        let name = "기타"

        let group = alarmGroupsRelay.value.first(where: { $0.name == name })
        let id = group?.id ?? UUID()

        let lastOrder = alarmGroupsRelay.value.map(\.order).max() ?? -1
        let order = lastOrder + 1

        return AlarmGroupDisplay(
            id: id,
            name: name,
            order: order,
            alarms: []
        )
    }

    private func makeDefaultAlarmDisplay() -> AlarmDisplay {
        .init()
    }

    func currentIsEditing() -> Bool {
        isEditingRelay.value
    }

    func selectEditingAlarm(_ alarm: AlarmDisplay, _ alarmGroup: AlarmGroupDisplay) {
        alarmRelay.accept(alarm)
        groupRelay.accept(alarmGroup)
        timeRelay.accept(alarm.time.raw)
        repeatDaysRelay.accept(alarm.repeatDays)
        labelRelay.accept(alarm.label)
        soundRelay.accept(alarm.sound)
        isSnoozeRelay.accept(alarm.isSnooze)
    }

    func deleteGroupIfEmpty(groupID: UUID) async {
        guard let groupIndex = groupIndex(for: groupID),
              alarmGroupsRelay.value[groupIndex].alarms.isEmpty
        else {
            return
        }

        do {
            try await deleteAlarmGroupUseCase.execute(groupID)

            var groups = alarmGroupsRelay.value
            groups.remove(at: groupIndex)

            alarmGroupsRelay.accept(groups)
        } catch {}
    }

    func updateIsSwiping(_ isSwiping: Bool) {
        isSwipingRelay.accept(isSwiping)
    }

    func updateIsEditing(_ isEditing: Bool) {
        isEditingRelay.accept(isEditing)
    }
}

extension DefaultAlarmViewModel {
    var saveButtonTapped: AnyObserver<Void> { saveButtonTappedSubject.asObserver() }
    var updateTime: AnyObserver<Date> { updateTimeSubject.asObserver() }
    var updateLabel: AnyObserver<AlarmLabelDisplay> { updateLabelSubject.asObserver() }
    var updateIsSnooze: AnyObserver<Bool> { updateIsSnoozeSubject.asObserver() }

    var saveCompleted: Observable<Void> { saveCompletedSubject.asObservable() }
    var group: Observable<AlarmGroupDisplay> { groupRelay.asObservable() }
    var alarm: Observable<AlarmDisplay> { alarmRelay.asObservable() }
    var time: Observable<Date> { timeRelay.asObservable() }
    var repeatDays: Observable<AlarmRepeatDaysDisplay> { repeatDaysRelay.asObservable() }
    var label: Observable<AlarmLabelDisplay> { labelRelay.asObservable() }
    var sound: Observable<SoundDisplay> { soundRelay.asObservable() }
    var isSnooze: Observable<Bool> { isSnoozeRelay.asObservable() }

    private func bindAlarmDetail() {
        updateTimeSubject
            .bind(to: timeRelay)
            .disposed(by: disposeBag)

        updateLabelSubject
            .bind(to: labelRelay)
            .disposed(by: disposeBag)

        updateIsSnoozeSubject
            .bind(to: isSnoozeRelay)
            .disposed(by: disposeBag)

        saveButtonTappedSubject
            .flatMapLatest { [weak self] in
                guard let self else { return Observable<(Alarm, AlarmGroup)>.empty() }

                return self.createAlarm()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] alarm, group in
                guard let self else { return }

                self.applyAlarmChanges(alarm: alarm, group: group)
            })
            .disposed(by: disposeBag)
    }

    private func editAlarm() -> (AlarmDisplay, AlarmGroupDisplay) {
        var alarm = alarmRelay.value
        var group = groupRelay.value

        group.name = groupRelay.value.name

        alarm.time = .init(raw: timeRelay.value)
        alarm.label = labelRelay.value
        alarm.repeatDays = repeatDaysRelay.value
        alarm.sound = soundRelay.value
        alarm.isSnooze = isSnoozeRelay.value

        return (alarm, group)
    }

    private func createAlarm() -> Observable<(Alarm, AlarmGroup)> {
        let (alarmDisplay, groupDisplay) = editAlarm()

        let alarm = mapper.mapToAlarm(alarmDisplay)
        let group = mapper.mapToAlarmGroup(groupDisplay)

        return Observable.create { observer in
            let task = Task {
                do {
                    try await self.createAlarmUseCase.execute(alarm, into: group)
                    observer.onNext((alarm, group))
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }

            return Disposables.create { task.cancel() }
        }
    }

    private func applyAlarmChanges(alarm: Alarm, group: AlarmGroup) {
        let displayAlarm = mapper.mapToAlarmDisplay(alarm)
        let displayGroup = mapper.mapToAlarmGroupDisplay(group)

        var groups = alarmGroupsRelay.value

        if let groupIndex = groups.firstIndex(where: { $0.id == displayGroup.id }) {
            groups[groupIndex].alarms.append(displayAlarm)
        } else {
            var newGroup = displayGroup
            newGroup.alarms = [displayAlarm]
            groups.append(newGroup)
        }

        let sortedGroups = groups
            .sorted(by: { $0.order < $1.order })
            .map { group in
                var sortedGroup = group
                sortedGroup.alarms.sort(by: { $0.time.raw < $1.time.raw })
                return sortedGroup
            }

        alarmGroupsRelay.accept(sortedGroups)
        saveCompletedSubject.onNext(())
    }
}

extension DefaultAlarmViewModel {
    var selectedGroup: Observable<AlarmGroupDisplay> { groupRelay.asObservable() }

    func updateTypingGroup(_ name: String) {
        var group = groupRelay.value
        group.name = name

        groupRelay.accept(group)
    }

    func updateSelectedGroup(_ group: AlarmGroupDisplay) {
        groupRelay.accept(group)
    }

    func currentGroups() -> [AlarmGroupDisplay] {
        let groups = alarmGroupsRelay.value
        let hasETC = groups.contains { $0.name == "기타" }

        if hasETC {
            return groups
        } else {
            let etcGroup = AlarmGroupDisplay()

            return groups + [etcGroup]
        }
    }

    func currentSelectedGroup() -> AlarmGroupDisplay {
        groupRelay.value
    }
}

extension DefaultAlarmViewModel {
    var selectedWeekdays: Observable<AlarmRepeatDaysDisplay> {  repeatDaysRelay.asObservable() }

    func toggleWeekday(_ weekday: Int) {
        var selected = repeatDaysRelay.value

        if selected.raw.contains(weekday) {
            selected.raw.remove(weekday)
        } else {
            selected.raw.insert(weekday)
        }

        repeatDaysRelay.accept(selected)
    }

    func currentSelectedWeekdays() -> [AlarmWeekdayType] {
        repeatDaysRelay.value.types
    }
}

extension DefaultAlarmViewModel {
    var selectedSound: Observable<SoundDisplay> { soundRelay.asObservable() }

    func updateSelectedSound(_ sound: SoundDisplay) {
        soundRelay.accept(sound)
    }

    func currentSelectedSound() -> SoundDisplay {
        soundRelay.value
    }
}
