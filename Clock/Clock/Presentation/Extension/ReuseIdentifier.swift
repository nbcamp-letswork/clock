protocol ReuseIdentifier {
    static var identifier: String { get }
}

extension ReuseIdentifier {
    static var identifier: String {
        String(describing: self)
    }
}
