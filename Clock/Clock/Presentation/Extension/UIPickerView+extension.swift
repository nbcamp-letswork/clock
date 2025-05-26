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
        let padding: CGFloat = 16

        for i in 0..<count {
            let label = UILabel()
            label.text = labels[i]
            label.textColor = .white
            label.textAlignment = .center
            label.font = .systemFont(ofSize: fontSize, weight: .bold)

            var labelX: CGFloat = (pickerWidth / CGFloat(count)) * CGFloat(i + 1) - padding
            if i == 0 { labelX -= padding }
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
