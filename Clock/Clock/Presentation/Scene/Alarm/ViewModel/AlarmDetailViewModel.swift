import RxSwift
import RxRelay
import Foundation

protocol AlarmDetailViewModel: AlarmDetailViewModelInput, AlarmDetailViewModelOutput {}

protocol AlarmDetailViewModelInput {
    var saveButtonTapped: AnyObserver<Void> { get }
    var updateTime: AnyObserver<Date> { get }
    var updateGroup: AnyObserver<String> { get }
    var updateRepeatDays: AnyObserver<AlarmRepeatDaysDisplay> { get }
    var updateLabel: AnyObserver<AlarmLabelDisplay> { get }
    var updateSound: AnyObserver<SoundDisplay> { get }
    var toggleSnoozeSwitch: AnyObserver<Bool> { get }
}

protocol AlarmDetailViewModelOutput {
    var saveCompleted: Observable<Void> { get }
    var time: Observable<Date> { get }
    var groupName: Observable<String> { get }
    var repeatDays: Observable<AlarmRepeatDaysDisplay> { get }
    var label: Observable<AlarmLabelDisplay> { get }
    var sound: Observable<SoundDisplay> { get }
    var isSnooze: Observable<Bool> { get }
}
