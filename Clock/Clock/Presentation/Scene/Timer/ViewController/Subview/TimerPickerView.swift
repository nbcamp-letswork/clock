//
//  TimerPickerView.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TimerPickerView: UIPickerView {
    private let disposeBag = DisposeBag()

    private let hour = BehaviorRelay<Int>(value: 0)
    private let minute = BehaviorRelay<Int>(value: 0)
    private let second = BehaviorRelay<Int>(value: 0)
    let timeRelay = PublishRelay<Int>()

    private let time = [
        (0...23).map{ String($0) },
        (0...59).map{ String($0) },
        (0...59).map{ String($0) }
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)

        setAttributes()
        setDelegate()
        setDataSource()
        setBidings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension TimerPickerView {
    func setAttributes() {
        self.setPickerLabels(labels: ["시간", "분", "초"])
    }

    func setDelegate() {
        self.delegate = self
    }

    func setDataSource() {
        self.dataSource = self
    }

    func setBidings() {
        Observable.combineLatest(hour, minute, second)
            .map{ ($0.0 * 24 + $0.1 * 60 + $0.2 * 60) * 1000 }
            .bind(to: timeRelay)
            .disposed(by: disposeBag)
    }
}

extension TimerPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return time.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return time[component].count
    }
}

extension TimerPickerView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return time[component][row]
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let value = Int(time[component][row]) else { return }
        switch component {
        case 0: hour.accept(value)
        case 1: minute.accept(value)
        case 2: second.accept(value)
        default:
            return
        }
    }
}
