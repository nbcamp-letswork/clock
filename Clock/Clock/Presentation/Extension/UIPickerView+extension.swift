//
//  UIPickerView+extension.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit

extension UIPickerView {
    func setTimePickerLabels() {
        let labels = ["시간", "분", "초"]
        let count = labels.count
        let fontSize: CGFloat = 20
        let pickerWidth: CGFloat = self.superview?.bounds.width ?? UIScreen.main.bounds.width
        let labelY: CGFloat = (self.frame.size.height / 2) - (fontSize / 2)
        let padding: CGFloat = 5

        for i in 0..<count {
            let label = UILabel()
            label.text = labels[i]
            label.textColor = .white
            label.textAlignment = .center
            label.font = .systemFont(ofSize: fontSize, weight: .bold)

            let width = fontSize * CGFloat(labels[i].count)
            var labelX: CGFloat = (pickerWidth / CGFloat(count)) * (CGFloat(i) + 0.5) - padding
            if i == 0 { labelX += 15 }
            else if i == 2 { labelX -= 15 }

            label.frame = CGRect(
                x: labelX,
                y: labelY,
                width: width,
                height: fontSize
            )
            self.addSubview(label)
        }
    }
}
