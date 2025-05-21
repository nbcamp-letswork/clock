import Foundation
import RxSwift
import RxRelay

final class AlarmViewModelImpl: AlarmViewModel {
    private let fetchAlarmUseCase: FetchableAlarmUseCase
    private let disposeBag = DisposeBag()

    let viewDidLoad: AnyObserver<Void>
    let toggleSwitch: AnyObserver<(groupID: UUID, alarmID: UUID, isOn: Bool)>

    let alarmGroups: Observable<[AlarmGroupDisplay]>

    private let viewDidLoadSubject = PublishSubject<Void>()
    private let toggleSwitchSubject = PublishSubject<(groupID: UUID, alarmID: UUID, isOn: Bool)>()

    private let alarmGroupsRelay = BehaviorRelay<[AlarmGroupDisplay]>(value: [])

    private var currentGroups: [AlarmGroupDisplay] = []

    init(fetchAlarmUseCase: FetchableAlarmUseCase) {
        self.fetchAlarmUseCase = fetchAlarmUseCase

        self.viewDidLoad = viewDidLoadSubject.asObserver()
        self.toggleSwitch = toggleSwitchSubject.asObserver()

        self.alarmGroups = alarmGroupsRelay.asObservable()

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
                                .sorted(by: { $0.order < $1.order })
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
    }

    private func updateAlarmEnabled(groupID: UUID, alarmID: UUID, isEnabled: Bool) {
        guard let groupIndex = currentGroups.firstIndex(where: { $0.id == groupID }) else { return }
        guard let alarmIndex = currentGroups[groupIndex].alarms.firstIndex(where: { $0.id == alarmID }) else { return }

        currentGroups[groupIndex].alarms[alarmIndex].isEnabled = isEnabled
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
