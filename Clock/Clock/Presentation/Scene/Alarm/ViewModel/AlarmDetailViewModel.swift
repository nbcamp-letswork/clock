import RxSwift
import RxRelay
import Foundation

protocol AlarmDetailViewModel: AlarmDetailViewModelInput, AlarmDetailViewModelOutput {}

protocol AlarmDetailViewModelInput {
    var saveButtonTapped: AnyObserver<Void> { get }
    var updateTime: AnyObserver<Date> { get }
    var updateLabel: AnyObserver<AlarmLabelDisplay> { get }
    var updateIsSnooze: AnyObserver<Bool> { get }
}

protocol AlarmDetailViewModelOutput {
    var saveCompleted: Observable<Void> { get }
    var group: Observable<AlarmGroupDisplay> { get }
    var alarm: Observable<AlarmDisplay> { get }
    var time: Observable<Date> { get }
    var repeatDays: Observable<AlarmRepeatDaysDisplay> { get }
    var label: Observable<AlarmLabelDisplay> { get }
    var sound: Observable<SoundDisplay> { get }
    var isSnooze: Observable<Bool> { get }
}
