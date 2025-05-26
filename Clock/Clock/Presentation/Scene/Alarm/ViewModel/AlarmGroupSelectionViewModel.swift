import RxSwift

protocol AlarmGroupSelectionViewModel: AlarmGroupSelectionViewModelInput, AlarmGroupSelectionViewModelOutput {}

protocol AlarmGroupSelectionViewModelInput {
    func updateTypingGroup(_ name: String)
    func updateSelectedGroup(_ group: AlarmGroupDisplay)
}

protocol AlarmGroupSelectionViewModelOutput {
    var selectedGroup: Observable<AlarmGroupDisplay> { get }

    func currentGroups() -> [AlarmGroupDisplay]
    func currentSelectedGroup() -> AlarmGroupDisplay
}
