//
//  UIPickerView+extension.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit

extension UIPickerView {
    func setPickerLabels(labels: [String]) {
        let count = labels.count
        let fontSize: CGFloat = 20
        let pickerWidth: CGFloat = self.frame.width
        let labelY: CGFloat = (self.frame.size.height / 2) - fontSize + 2

        for i in 0..<count {
            let label = UILabel()
            label.text = labels[i]
            label.textColor = .white
            label.font = .systemFont(ofSize: fontSize, weight: .bold)

            let labelX: CGFloat = (pickerWidth / CGFloat(count)) * CGFloat(i + 1) - fontSize * 1.5

            label.frame = CGRect(
                x: labelX,
                y: labelY,
                width: fontSize * CGFloat(labels[i].count),
                height: fontSize
            )
            self.addSubview(label)
        }
    }
}
