import RxSwift
import Foundation

protocol AlarmViewModel: AlarmViewModelInput, AlarmViewModelOutput {}

protocol AlarmViewModelInput {
    var viewDidLoad: AnyObserver<Void> { get }
    var toggleSwitch: AnyObserver<(groupID: UUID, alarmID: UUID, isOn: Bool)> { get }
    var editButtonTapped: AnyObserver<Void> { get }
    var deleteAlarm: AnyObserver<(groupID: UUID, alarmID: UUID)> { get }
}

protocol AlarmViewModelOutput {
    var alarmGroups: Observable<[AlarmGroupDisplay]> { get }
    var isEditing: Observable<Bool> { get }
}
