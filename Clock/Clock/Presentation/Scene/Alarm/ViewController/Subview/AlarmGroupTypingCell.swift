import UIKit
import RxRelay
import RxSwift

final class AlarmGroupTypingCell: UITableViewCell, ReuseIdentifier {
    var disposeBag = DisposeBag()

    let labelRelay = PublishRelay<String>()

    private let titleLabel = UILabel()
    private let textField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setAttributes()
        setHierarchy()
        setConstraints()
        setBindings()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }

    func configure(with text: String?) {
        textField.text = text
    }

    func focusTextField() {
        textField.becomeFirstResponder()
    }

    func text() -> String? {
        textField.text
    }

    @objc
    private func textDidChange(_ textField: UITextField) {
        let isEmpty = textField.text?.isEmpty ?? true

        textField.snp.updateConstraints {
            $0.trailing.equalToSuperview().inset(isEmpty ? 20 : 14)
        }
    }
}

private extension AlarmGroupTypingCell {
    func setAttributes() {
        titleLabel.text = "이름"

        textField.placeholder = "기타"
        textField.textColor = .secondaryLabel
        textField.tintColor = .systemOrange
        textField.borderStyle = .none
        textField.textAlignment = .right
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }

    func setHierarchy() {
        [titleLabel, textField]
            .forEach { contentView.addSubview($0) }
    }

    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        textField.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }

    func setBindings() {
        textField.rx.text
            .orEmpty
            .skip(1)
            .bind(to: labelRelay)
            .disposed(by: disposeBag)
    }
}
