import RxSwift
import RxRelay
import Foundation

protocol AlarmListViewModel: AlarmListViewModelInput, AlarmListViewModelOutput {
    func currentIsEditing() -> Bool
    func selectEditingAlarm(_ alarm: AlarmDisplay, _ alarmGroup: AlarmGroupDisplay)
    func deleteGroupIfEmpty(groupID: UUID) async
}

protocol AlarmListViewModelInput {
    var viewDidLoad: AnyObserver<Void> { get }
    var toggleSwitch: AnyObserver<(groupID: UUID, alarmID: UUID, isOn: Bool)> { get }
    var editButtonTapped: AnyObserver<Void> { get }
    var deleteAlarm: AnyObserver<(groupID: UUID, alarmID: UUID)> { get }
    var plusButtonTapped: AnyObserver<Void> { get }
    var alarmCellTapped: AnyObserver<(AlarmDisplay, AlarmGroupDisplay)> { get }

    func updateIsSwiping(_ isSwiping: Bool)
    func updateIsEditing(_ isEditing: Bool)
}

protocol AlarmListViewModelOutput {
    var alarmGroups: Observable<[AlarmGroupDisplay]> { get }
    var isEditing: Observable<Bool> { get }
    var isSwiping: Observable<Bool> { get }
    var showCreateAlarm: Observable<(AlarmDisplay, AlarmGroupDisplay)> { get }
    var showUpdateAlarm: Observable<(AlarmDisplay, AlarmGroupDisplay)> { get }
}
