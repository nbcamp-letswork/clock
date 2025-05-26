import RxSwift

protocol AlarmRepeatDaysSelectionViewModel: AlarmRepeatDaysSelectionViewModelInput, AlarmRepeatDaysSelectionViewModelOutput {}

protocol AlarmRepeatDaysSelectionViewModelInput {
    func toggleWeekday(_ weekday: Int)
}

protocol AlarmRepeatDaysSelectionViewModelOutput {
    var selectedWeekdays: Observable<AlarmRepeatDaysDisplay> { get }

    func currentSelectedWeekdays() -> [AlarmWeekdayType]
}
