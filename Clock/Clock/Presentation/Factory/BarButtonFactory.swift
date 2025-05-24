import UIKit

enum BarButtonFactory {
    static func customButton(with title: String) -> UIBarButtonItem {
        let item = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        item.tintColor = .systemOrange

        return item
    }

    static func plusButton() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        item.tintColor = .systemOrange

        return item
    }
}
