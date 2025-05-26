final class DIContainer {
    private let alarmStorage: AlarmStorage = CoreDataAlarmStorage()

    func makeFetchableAlarmUseCase() -> FetchableAlarmUseCase {
        FetchAlarmUseCase(alarmGroupRepository: DefaultAlarmGroupRepository(storage: alarmStorage))
    }

    func makeSortableAlarmUseCase() -> SortableAlarmUseCase {
        SortAlarmUseCase()
    }

    func makeCreatableAlarmUseCase() -> CreatableAlarmUseCase {
        CreateAlarmUseCase(
            alarmGroupRepository: DefaultAlarmGroupRepository(storage: alarmStorage),
            alarmRepository: DefaultAlarmRepository(storage: alarmStorage)
        )
    }

    func makeDeleteAlarmUseCase() -> DeletableAlarmUseCase {
        DeleteAlarmUseCase(alarmRepository: DefaultAlarmRepository(storage: alarmStorage))
    }

    func makeUpdatableAlarmUseCase() -> UpdatableAlarmUseCase {
        UpdateAlarmUseCase(
            alarmRepository: DefaultAlarmRepository(storage: alarmStorage),
            alarmGroupRepository: DefaultAlarmGroupRepository(storage: alarmStorage)
        )
    }

    func makeDeleteAlarmGroupUseCase() -> DeletableAlarmGroupUseCase {
        DeleteAlarmGroupUseCase(alarmGroupRepository: DefaultAlarmGroupRepository(storage: alarmStorage))
    }

    func makeAlarmViewModel() -> AlarmViewModel {
        DefaultAlarmViewModel(
            fetchAlarmUseCase: makeFetchableAlarmUseCase(),
            sortAlarmUseCase: makeSortableAlarmUseCase(),
            createAlarmUseCase: makeCreatableAlarmUseCase(),
            deleteAlarmUseCase: makeDeleteAlarmUseCase(),
            updateAlarmUseCase: makeUpdatableAlarmUseCase(),
            deleteAlarmGroupUseCase: makeDeleteAlarmGroupUseCase()
        )
    }

    func makeFechableRecentTimerUseCase() -> FetchableRecentTimerUseCase {
        FetchRecentTimerUseCase()
    }

    func makeFetchableOngoingTimerUseCase() -> FetchableOngoingTimerUseCase {
        FetchOngoingTimerUseCase()
    }

    func makeCreatableTimerUseCase() -> CreatableTimerUseCase {
        CreateTimerUseCase()
    }

    func makeTimerViewModel() -> TimerViewModel {
        DefaultTimerViewModel(
            fetchRecentTimerUseCase: makeFechableRecentTimerUseCase(),
            fetchOngoingTimerUseCase: makeFetchableOngoingTimerUseCase(),
            createTimerUseCase: makeCreatableTimerUseCase()
        )
    }
}
