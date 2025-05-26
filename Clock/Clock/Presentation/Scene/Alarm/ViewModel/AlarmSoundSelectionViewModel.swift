import RxSwift

protocol AlarmSoundSelectionViewModel: AlarmSoundSelectionViewModelInput, AlarmSoundSelectionViewModelOutput {}

protocol AlarmSoundSelectionViewModelInput {
    func updateSelectedSound(_ sound: SoundDisplay)
}

protocol AlarmSoundSelectionViewModelOutput {
    var selectedSound: Observable<SoundDisplay> { get }

    func currentSelectedSound() -> SoundDisplay
}
