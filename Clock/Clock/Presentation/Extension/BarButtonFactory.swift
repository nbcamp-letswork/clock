import UIKit

enum BarButtonFactory {
    static func editButton(target: Any, action: Selector) -> UIBarButtonItem {
        let item = UIBarButtonItem(title: "편집", style: .plain, target: target, action: action)
        item.tintColor = .systemOrange
        item.setTitleTextAttributes([
            .font: UIFont.boldSystemFont(ofSize: 17)
        ], for: .normal)

        return item
    }

    static func plusButton(target: Any, action: Selector) -> UIBarButtonItem {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: config)
        let item = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        item.tintColor = .systemOrange

        return item
    }
}
