final class DIContainer {
    func makeFetchableAlarmUseCase() -> FetchableAlarmUseCase {
        FetchAlarmUseCase()
    }

    func makeAlarmViewModel() -> AlarmViewModel {
        AlarmViewModelImpl(fetchAlarmUseCase: makeFetchableAlarmUseCase())
    }
}
