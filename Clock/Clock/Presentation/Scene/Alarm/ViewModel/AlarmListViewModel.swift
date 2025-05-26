import RxSwift
import RxRelay
import Foundation

protocol AlarmListViewModel: AlarmListViewModelInput, AlarmListViewModelOutput {
    func currentIsEditing() -> Bool
    func select(_ alarm: AlarmDisplay, _ alarmGroup: AlarmGroupDisplay)
    func deleteGroupIfEmpty(groupID: UUID) async
}

protocol AlarmListViewModelInput {
    var viewDidLoad: AnyObserver<Void> { get }
    var toggleSwitch: AnyObserver<(groupID: UUID, alarmID: UUID, isOn: Bool)> { get }
    var editButtonTapped: AnyObserver<Void> { get }
    var deleteAlarm: AnyObserver<(groupID: UUID, alarmID: UUID)> { get }
    var plusButtonTapped: AnyObserver<Void> { get }

    func updateIsSwiping(_ isSwiping: Bool)
    func updateIsEditing(_ isEditing: Bool)
}

protocol AlarmListViewModelOutput {
    var alarmGroups: Observable<[AlarmGroupDisplay]> { get }
    var isEditing: Observable<Bool> { get }
    var isSwiping: Observable<Bool> { get }
    var showAlarmDetail: Observable<(AlarmDisplay, AlarmGroupDisplay)> { get }
}
