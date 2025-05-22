final class DIContainer {
    func makeFetchableAlarmUseCase() -> FetchableAlarmUseCase {
        FetchAlarmUseCase()
    }

    func makeAlarmViewModel() -> AlarmViewModel {
        DefaultAlarmViewModel(fetchAlarmUseCase: makeFetchableAlarmUseCase())
    }
}
