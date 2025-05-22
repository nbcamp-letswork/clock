final class DIContainer {
    func makeFetchableAlarmUseCase() -> FetchableAlarmUseCase {
        FetchAlarmUseCase()
    }

    func makeAlarmViewModel() -> AlarmViewModel {
        DefaultAlarmViewModel(fetchAlarmUseCase: makeFetchableAlarmUseCase())
    }

    func makeFechableRecentTimerUseCase() -> FetchableRecentTimerUseCase {
        FetchRecentTimerUseCase()
    }

    func makeFetchableOngoingTimerUseCase() -> FetchableOngoingTimerUseCase {
        FetchOngoingTimerUseCase()
    }

    func makeTimerViewModel() -> TimerViewModel {
        DefaultTimerViewModel(
            fetchRecentTimerUseCase: makeFechableRecentTimerUseCase(),
            fetchOngoingTimerUseCase: makeFetchableOngoingTimerUseCase()
        )
    }
}
