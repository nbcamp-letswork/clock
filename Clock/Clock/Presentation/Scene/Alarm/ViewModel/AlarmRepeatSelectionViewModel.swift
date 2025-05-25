import RxSwift

protocol AlarmRepeatSelectionViewModel: AlarmRepeatSelectionViewModelInput, AlarmRepeatSelectionViewModelOutput {}

protocol AlarmRepeatSelectionViewModelInput {
    func toggleWeekday(_ weekday: Int)
}

protocol AlarmRepeatSelectionViewModelOutput {
    var selectedWeekdays: Observable<AlarmRepeatDaysDisplay> { get }

    func currentSelectedWeekdays() -> [AlarmWeekdayType]
}
