//
//  TimerPickerView.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit

final class TimerPickerView: UIPickerView {
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
}
