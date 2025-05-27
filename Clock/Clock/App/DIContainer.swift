final class DIContainer {
    private let alarmStorage: AlarmStorage = CoreDataAlarmStorage()
    private let timerStorage: TimerStorage
    private let timerRepository: TimerRepository

    let alarmNotificationService: AlarmNotificationService = DefaultAlarmNotificationService()

    init() {
        timerStorage = CoreDataTimerStorage()
        timerRepository = DefaultTimerRepository(storage: timerStorage)
    }

    func makeFetchableAllTimerUseCase() -> FetchableAllTimerUseCase {
        FetchAllTimerUseCase(repository: timerRepository)
    }

    func makeCreatableTimerUseCase() -> CreatableTimerUseCase {
        CreateTimerUseCase(repository: timerRepository)
    }

    func makeDeletableTimerUseCase() -> DeletableTimerUseCase {
        DeleteTimerUseCase(repository: timerRepository)
    }

    func makeUpdatableTimerUseCase() -> UpdatableTimerUseCase {
        UpdateTimerUseCase(repository: timerRepository)
    }

    func makeTimerViewModel() -> TimerViewModel {
        DefaultTimerViewModel(
            fetchAllTimerUseCase: makeFetchableAllTimerUseCase(),
            createTimerUseCase: makeCreatableTimerUseCase(),
            deleteTimerUseCase: makeDeletableTimerUseCase(),
            updateTimerUseCase: makeUpdatableTimerUseCase()
        )
    }
    
    func makeStopwatchRepository() -> StopwatchRepository {
        DefaultStopwatchRepository(storage: CoreDataStopwatchStorage())
    }
    
    func makeStopwatchViewModel() -> StopwatchViewModel {
        DefaultStopwatchViewModel(
            fetchUseCase: makeFetchableStopwatchUseCase(),
            createUseCase: makeCreatableStopwatchUseCase(),
            deleteUseCase: makeDeletableStopwatchUseCase()
        )
    }
    
    func makeFetchableStopwatchUseCase() -> FetchableStopwatchUseCase {
        FetchStopwatchUseCase(repository: makeStopwatchRepository())
    }

    func makeCreatableStopwatchUseCase() -> CreatableStopwatchUseCase {
        CreateStopwatchUseCase(repository: makeStopwatchRepository())
    }

    func makeDeletableStopwatchUseCase() -> DeletableStopwatchUseCase {
        DeleteStopwatchUseCase(repository: makeStopwatchRepository())
    }
}

extension DIContainer {
    func makeAlarmRepository() -> AlarmRepository {
        DefaultAlarmRepository(storage: alarmStorage)
    }

    func makeAlarmGroupRepositroy() -> AlarmGroupRepository {
        DefaultAlarmGroupRepository(storage: alarmStorage)
    }

    func makeAlarmNotificationRepository() -> AlarmNotificationRepository {
        DefaultAlarmNotificationRepository(service: alarmNotificationService)
    }

    func makeFetchableAlarmGroupUseCase() -> FetchableAlarmGroupUseCase {
        FetchAlarmGroupUseCase(alarmGroupRepository: makeAlarmGroupRepositroy())
    }

    func makeCreatableAlarmUseCase() -> CreatableAlarmUseCase {
        CreateAlarmUseCase(
            alarmGroupRepository: makeAlarmGroupRepositroy(),
            alarmRepository: makeAlarmRepository()
        )
    }

    func makeUpdatableAlarmUseCase() -> UpdatableAlarmUseCase {
        UpdateAlarmUseCase(
            alarmRepository: makeAlarmRepository(),
            alarmGroupRepository: makeAlarmGroupRepositroy()
        )
    }

    func makeDeleteAlarmUseCase() -> DeletableAlarmUseCase {
        DeleteAlarmUseCase(alarmRepository: makeAlarmRepository())
    }

    func makeDeleteAlarmGroupUseCase() -> DeletableAlarmGroupUseCase {
        DeleteAlarmGroupUseCase(alarmGroupRepository: makeAlarmGroupRepositroy())
    }

    func makeSortableAlarmUseCase() -> SortableAlarmUseCase {
        SortAlarmUseCase()
    }

    func makeRequestableAuthorizationUseCase() -> RequestableAuthorizationUseCase{
        RequesteAuthorizationUseCase(alarmNotificationRepository: makeAlarmNotificationRepository())
    }

    func makeSchedulableAlarmNotificationUseCase() -> SchedulableAlarmNotificationUseCase {
        ScheduleAlarmNotificationUseCase(alarmNotificationRepository: makeAlarmNotificationRepository())
    }

    func makeSchedulableSnoozeAlarmNotificationUseCase() -> SchedulableSnoozeAlarmNotificationUseCase {
        ScheduleSnoozeAlarmNotificationUseCase(
            alarmNotificationRepository: makeAlarmNotificationRepository(),
            alarmRepository: makeAlarmRepository(),
        )
    }

    func makeCancelableAlarmNotificationUseCase() -> CancelableAlarmNotificationUseCase {
        CancelAlarmNotificationUseCase(alarmNotificationRepository: makeAlarmNotificationRepository())
    }

    func makeAlarmViewModel() -> AlarmViewModel {
        DefaultAlarmViewModel(
            fetchAlarmGroupUseCase: makeFetchableAlarmGroupUseCase(),
            sortAlarmUseCase: makeSortableAlarmUseCase(),
            createAlarmUseCase: makeCreatableAlarmUseCase(),
            deleteAlarmUseCase: makeDeleteAlarmUseCase(),
            updateAlarmUseCase: makeUpdatableAlarmUseCase(),
            deleteAlarmGroupUseCase: makeDeleteAlarmGroupUseCase(),
            requestableAuthorizationUseCase: makeRequestableAuthorizationUseCase(),
            schedulableAlarmNotificationUseCase: makeSchedulableAlarmNotificationUseCase(),
            cancelableAlarmNotificationUseCase: makeCancelableAlarmNotificationUseCase()
        )
    }
}
