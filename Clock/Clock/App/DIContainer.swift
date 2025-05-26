final class DIContainer {
    private let alarmStorage: AlarmStorage = CoreDataAlarmStorage()
    private let timerStorage: TimerStorage = CoreDataTimerStorage()

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

    func makeDeleteAlarmGroupUseCase() -> DeletableAlarmGroupUseCase {
        DeleteAlarmGroupUseCase(alarmGroupRepository: DefaultAlarmGroupRepository(storage: alarmStorage))
    }

    func makeAlarmViewModel() -> AlarmViewModel {
        DefaultAlarmViewModel(
            fetchAlarmUseCase: makeFetchableAlarmUseCase(),
            sortAlarmUseCase: makeSortableAlarmUseCase(),
            createAlarmUseCase: makeCreatableAlarmUseCase(),
            deleteAlarmUseCase: makeDeleteAlarmUseCase(),
            deleteAlarmGroupUseCase: makeDeleteAlarmGroupUseCase()
        )
    }
    
    func makeFetchableAllTimerUseCase() -> FetchableAllTimerUseCase {
        FetchAllTimerUseCase(repository: DefaultTimerRepository(storage: timerStorage))
    }

    func makeCreatableTimerUseCase() -> CreatableTimerUseCase {
        CreateTimerUseCase()
    }

    func makeTimerViewModel() -> TimerViewModel {
        DefaultTimerViewModel(
            fetchAllTimerUseCase: makeFetchableAllTimerUseCase(),
            createTimerUseCase: makeCreatableTimerUseCase()
        )
    }
}
