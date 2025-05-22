final class DIContainer {
    func makeFetchableAlarmUseCase() -> FetchableAlarmUseCase {
        FetchAlarmUseCase()
    }

    func makeAlarmViewModel() -> AlarmViewModel {
        DefaultAlarmViewModel(fetchAlarmUseCase: makeFetchableAlarmUseCase())
    }

    func makeFechableRecentTimerUseCase() -> FetchRecentTimerUseCase {
        FetchRecentTimerUseCase()
    }

    func makeTimerViewModel() -> TimerViewModel {
        DefaultTimerViewModel(fetchRecentTimerUseCase: makeFechableRecentTimerUseCase())
    }
}
