import Foundation
import RxSwift
import RxRelay

final class DefaultAlarmViewModel: AlarmViewModel {
    private let fetchAlarmUseCase: FetchableAlarmUseCase
    private let disposeBag = DisposeBag()

    let viewDidLoad: AnyObserver<Void>
    let toggleSwitch: AnyObserver<(groupID: UUID, alarmID: UUID, isOn: Bool)>
    let editButtonTapped: AnyObserver<Void>
    var deleteAlarm: AnyObserver<(groupID: UUID, alarmID: UUID)>

    let alarmGroups: Observable<[AlarmGroupDisplay]>
    let isEditing: Observable<Bool>

    private let viewDidLoadSubject = PublishSubject<Void>()
    private let toggleSwitchSubject = PublishSubject<(groupID: UUID, alarmID: UUID, isOn: Bool)>()
    private let editButtonTappedSubject = PublishSubject<Void>()
    private let deleteAlarmSubject = PublishSubject<(groupID: UUID, alarmID: UUID)>()

    private let alarmGroupsRelay = BehaviorRelay<[AlarmGroupDisplay]>(value: [])
    private let isEditingRelay = BehaviorRelay<Bool>(value: false)

    private var currentGroups: [AlarmGroupDisplay] = []

    init(fetchAlarmUseCase: FetchableAlarmUseCase) {
        self.fetchAlarmUseCase = fetchAlarmUseCase

        self.viewDidLoad = viewDidLoadSubject.asObserver()
        self.toggleSwitch = toggleSwitchSubject.asObserver()
        self.editButtonTapped = editButtonTappedSubject.asObserver()
        self.deleteAlarm = deleteAlarmSubject.asObserver()

        self.alarmGroups = alarmGroupsRelay.asObservable()
        self.isEditing = isEditingRelay.asObservable()

        bind()
    }

    private func bind() {
        viewDidLoadSubject
            .flatMapLatest { [weak self] _ -> Observable<[AlarmGroupDisplay]> in
                guard let self else { return .empty() }
                return Observable.create { observer in
                    Task {
                        do {
                            let domainGroups = try await self.fetchAlarmUseCase.execute()
                            let displayGroups = self.mapToAlarmGroupDisplay(domainGroups)
                            
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
                self?.currentGroups = groups
                self?.alarmGroupsRelay.accept(groups)
            })
            .disposed(by: disposeBag)

        toggleSwitchSubject
            .subscribe(onNext: { [weak self] groupID, alarmID, isOn in
                self?.updateAlarmEnabled(groupID: groupID, alarmID: alarmID, isEnabled: isOn)
            })
            .disposed(by: disposeBag)

        editButtonTappedSubject
            .withLatestFrom(isEditingRelay)
            .map { !$0 }
            .bind(to: isEditingRelay)
            .disposed(by: disposeBag)

        deleteAlarmSubject
            .subscribe(onNext: { [weak self] groupID, alarmID in
                self?.deleteAlarm(groupID: groupID, alarmID: alarmID)
            })
            .disposed(by: disposeBag)
    }

    func toggleEditing() {
        isEditingRelay.accept(!isEditingRelay.value)
    }

    private func groupIndex(for groupID: UUID) -> Int? {
        currentGroups.firstIndex(where: { $0.id == groupID })
    }

    private func alarmIndex(for alarmID: UUID, in groupIndex: Int) -> Int? {
        currentGroups[groupIndex].alarms.firstIndex(where: { $0.id == alarmID })
    }

    private func updateAlarmEnabled(groupID: UUID, alarmID: UUID, isEnabled: Bool) {
        guard let groupIndex = groupIndex(for: groupID),
              let alarmIndex = alarmIndex(for: alarmID, in: groupIndex)
        else {
            return
        }

        currentGroups[groupIndex].alarms[alarmIndex].isEnabled = isEnabled
        alarmGroupsRelay.accept(currentGroups)
    }

    private func deleteAlarm(groupID: UUID, alarmID: UUID) {
        guard let groupIndex = groupIndex(for: groupID),
              let alarmIndex = alarmIndex(for: alarmID, in: groupIndex)
        else {
            return
        }

        currentGroups[groupIndex].alarms.remove(at: alarmIndex)
        alarmGroupsRelay.accept(currentGroups)
    }

    private func mapToAlarmGroupDisplay(_ domainGroups: [AlarmGroup]) -> [AlarmGroupDisplay] {
        domainGroups.map { group in
            AlarmGroupDisplay(
                id: group.id,
                name: group.name,
                order: group.order,
                alarms: group.alarms.map { alarm in
                    return AlarmDisplay(alarm: alarm)
                }
            )
        }
    }
}
