import Foundation
import RxSwift
import RxRelay

final class DefaultAlarmViewModel: AlarmViewModel {
    private let fetchAlarmUseCase: FetchableAlarmUseCase
    private let sortAlarmUseCase: SortableAlarmUseCase
    private let createAlarmUseCase: CreatableAlarmUseCase
    private let deleteAlarmUseCase: DeletableAlarmUseCase
    private let updateAlarmUseCase: UpdatableAlarmUseCase
    private let deleteAlarmGroupUseCase: DeletableAlarmGroupUseCase

    private let mapper = AlarmMapper()

    private let disposeBag = DisposeBag()

    private let viewDidLoadSubject = PublishSubject<Void>()
    private let toggleSwitchSubject = PublishSubject<(groupID: UUID, alarmID: UUID, isOn: Bool)>()
    private let editButtonTappedSubject = PublishSubject<Void>()
    private let deleteAlarmSubject = PublishSubject<(groupID: UUID, alarmID: UUID)>()
    private let plusButtonTappedSubject = PublishSubject<Void>()
    private let alarmCellTappedSubject = PublishSubject<(AlarmDisplay, AlarmGroupDisplay)>()

    private let alarmGroupsRelay = BehaviorRelay<[AlarmGroupDisplay]>(value: [])
    private let isEditingRelay = BehaviorRelay<Bool>(value: false)
    private let isSwipingRelay = BehaviorRelay<Bool>(value: false)
    private let showCreateAlarmSubject = PublishSubject<(AlarmDisplay, AlarmGroupDisplay)>()
    private let showUpdateAlarmSubject = PublishSubject<(AlarmDisplay, AlarmGroupDisplay)>()

    private let saveButtonTappedSubject = PublishSubject<Void>()
    private let updateTimeSubject = PublishSubject<AlarmTimeDisplay>()
    private let updateLabelSubject = PublishSubject<AlarmLabelDisplay>()
    private let updateIsSnoozeSubject = PublishSubject<Bool>()

    private let saveCompletedSubject = PublishSubject<Void>()
    private let groupRelay = BehaviorRelay<AlarmGroupDisplay>(value: .init())
    private let alarmRelay = BehaviorRelay<AlarmDisplay>(value: .init())
    private let timeRelay = BehaviorRelay<AlarmTimeDisplay>(value: .init(raw: Date()))
    private let repeatDaysRelay = BehaviorRelay<AlarmRepeatDaysDisplay>(value: .init(raw: []))
    private let labelRelay = BehaviorRelay<AlarmLabelDisplay>(value: .init(raw: ""))
    private let soundRelay = BehaviorRelay<SoundDisplay>(value: .bell)
    private let isSnoozeRelay = BehaviorRelay<Bool>(value: false)

    private var isUpdatingAlarm = false

    init(
        fetchAlarmUseCase: FetchableAlarmUseCase,
        sortAlarmUseCase: SortableAlarmUseCase,
        createAlarmUseCase: CreatableAlarmUseCase,
        deleteAlarmUseCase: DeletableAlarmUseCase,
        updateAlarmUseCase: UpdatableAlarmUseCase,
        deleteAlarmGroupUseCase: DeletableAlarmGroupUseCase
    ) {
        self.fetchAlarmUseCase = fetchAlarmUseCase
        self.sortAlarmUseCase = sortAlarmUseCase
        self.createAlarmUseCase = createAlarmUseCase
        self.deleteAlarmUseCase = deleteAlarmUseCase
        self.updateAlarmUseCase = updateAlarmUseCase
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
    var alarmCellTapped: AnyObserver<(AlarmDisplay, AlarmGroupDisplay)> { alarmCellTappedSubject.asObserver() }

    var alarmGroups: Observable<[AlarmGroupDisplay]> { alarmGroupsRelay.asObservable() }
    var isEditing: Observable<Bool> { isEditingRelay.asObservable() }
    var isSwiping: Observable<Bool> { isSwipingRelay.asObservable() }
    var showCreateAlarm: Observable<(AlarmDisplay, AlarmGroupDisplay)> { showCreateAlarmSubject.asObservable() }
    var showUpdateAlarm: Observable<(AlarmDisplay, AlarmGroupDisplay)> { showUpdateAlarmSubject.asObservable() }

    private func bindAlarmList() {
        viewDidLoadSubject
            .flatMapLatest { [weak self] _ -> Observable<[AlarmGroupDisplay]> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    Task {
                        do {
                            let domainGroups = try await self.fetchAlarmUseCase.execute()
                            let sortedGroups = self.sortAlarmUseCase.execute(domainGroups)
                            let displayGroups = sortedGroups.map { self.mapper.mapToAlarmGroupDisplay($0) }

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
                    await self?.deleteGroupIfEmpty(groupID: groupID)
                }
            })
            .disposed(by: disposeBag)

        plusButtonTappedSubject
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                let alarm = self.makeDefaultAlarmDisplay()
                let group = self.makeDefaultAlarmGroupDisplay()

                self.selectEditingAlarm(alarm, group)
                self.showCreateAlarmSubject.onNext((alarm, group))
                self.isUpdatingAlarm = false
            })
            .disposed(by: disposeBag)

        alarmCellTappedSubject
            .subscribe(onNext: { [weak self] alarm, group in
                guard let self = self else { return }

                self.selectEditingAlarm(alarm, group)
                self.showUpdateAlarmSubject.onNext((alarm, group))
                self.isUpdatingAlarm = true
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

        let alarm = groups[groupIndex].alarms[alarmIndex]

        let domainAlarm = mapper.mapToAlarm(alarm)

        Task {
            do {
                try await updateAlarmUseCase.execute(domainAlarm)

                alarmGroupsRelay.accept(groups)
            } catch {}
        }
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
        timeRelay.accept(alarm.time)
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
    var updateTime: AnyObserver<AlarmTimeDisplay> { updateTimeSubject.asObserver() }
    var updateLabel: AnyObserver<AlarmLabelDisplay> { updateLabelSubject.asObserver() }
    var updateIsSnooze: AnyObserver<Bool> { updateIsSnoozeSubject.asObserver() }

    var saveCompleted: Observable<Void> { saveCompletedSubject.asObservable() }
    var group: Observable<AlarmGroupDisplay> { groupRelay.asObservable() }
    var alarm: Observable<AlarmDisplay> { alarmRelay.asObservable() }
    var time: Observable<AlarmTimeDisplay> { timeRelay.asObservable() }
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

                let (alarmDisplay, groupDisplay) = self.editAlarm()

                let alarm = self.mapper.mapToAlarm(alarmDisplay)
                let group = self.mapper.mapToAlarmGroup(groupDisplay)

                return self.isUpdatingAlarm
                    ? self.updateAlarm(alarm, group)
                    : self.createAlarm(alarm, group)
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

        if let existingGroup = alarmGroupsRelay.value.first(where: { $0.name == group.name }) {
            group.id = existingGroup.id
            group.order = existingGroup.order
        } else {
            group.id = UUID()
            let lastOrder = alarmGroupsRelay.value.map(\.order).max() ?? -1
            group.order = lastOrder + 1
        }

        alarm.time = timeRelay.value
        alarm.label = labelRelay.value
        alarm.repeatDays = repeatDaysRelay.value
        alarm.sound = soundRelay.value
        alarm.isSnooze = isSnoozeRelay.value

        return (alarm, group)
    }

    private func createAlarm(_ alarm: Alarm, _ group: AlarmGroup) -> Observable<(Alarm, AlarmGroup)> {
        Observable.create { [weak self] observer in
            let task = Task {
                do {
                    try await self?.createAlarmUseCase.execute(alarm, into: group)

                    observer.onNext((alarm, group))
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }

            return Disposables.create { task.cancel() }
        }
    }

    private func updateAlarm(_ alarm: Alarm, _ group: AlarmGroup) -> Observable<(Alarm, AlarmGroup)> {
        Observable.create { [weak self] observer in
            let task = Task {
                do {
                    try await self?.updateAlarmUseCase.execute(alarm, group)

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

        var currentGroups = alarmGroupsRelay.value

        var originalGroupHasAlarm = false
        var originalGroupID: UUID?

        for i in 0..<currentGroups.count {
            if let alarmIndex = currentGroups[i].alarms.firstIndex(where: { $0.id == displayAlarm.id }) {
                originalGroupID = currentGroups[i].id
                currentGroups[i].alarms.remove(at: alarmIndex)
                originalGroupHasAlarm = true

                break
            }
        }

        if let targetGroupIndex = currentGroups.firstIndex(where: { $0.id == displayGroup.id }) {
            currentGroups[targetGroupIndex].alarms.append(displayAlarm)
        } else {
            var newGroup = displayGroup
            newGroup.alarms = [displayAlarm]
            currentGroups.append(newGroup)
        }

        if originalGroupHasAlarm, let oldGroupID = originalGroupID, oldGroupID != displayGroup.id {
            if let oldGroupInCurrentListIndex = currentGroups.firstIndex(where: { $0.id == oldGroupID }) {
                if currentGroups[oldGroupInCurrentListIndex].alarms.isEmpty {
                    currentGroups.remove(at: oldGroupInCurrentListIndex)

                    Task {
                        await deleteGroupIfEmpty(groupID: oldGroupID)
                    }
                }
            }
        }

        let domainGroupsAfterChanges = currentGroups.map { mapper.mapToAlarmGroup($0) }
        let sortedDomainGroups = sortAlarmUseCase.execute(domainGroupsAfterChanges)
        let sortedDisplayGroups = sortedDomainGroups.map { mapper.mapToAlarmGroupDisplay($0) }

        alarmGroupsRelay.accept(sortedDisplayGroups)
        saveCompletedSubject.onNext(())
    }

    func currentLabel() -> AlarmLabelDisplay {
        labelRelay.value
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
