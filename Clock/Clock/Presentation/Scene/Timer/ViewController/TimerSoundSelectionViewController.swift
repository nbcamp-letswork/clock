//
//  TimerSoundSelectionViewController.swift
//  Clock
//
//  Created by 이수현 on 5/27/25.
//

import UIKit
import RxSwift

final class TimerSoundSelectionViewController: UIViewController {
    private let selectionView = TimerSoundSelectionView()
    private let viewModel: TimerSoundSelectionViewModel

    private let disposeBag = DisposeBag()

    override func loadView() {
        view = selectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setDelegate()
        setDataSource()
        setBindings()
    }

    init(viewModel: TimerSoundSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension TimerSoundSelectionViewController {

    func setDelegate() {
        selectionView.tableView.delegate = self
    }

    func setDataSource() {
        selectionView.tableView.dataSource = self
    }

    func setBindings() {
        navigationItem.leftBarButtonItem?.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
    }

    func setNavigationBar() {
        let popButton = BarButtonFactory.customButton(with: "뒤로")
        self.navigationItem.setLeftBarButton(popButton, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = false
        self.title = "타이머 종료 시"
    }
}

extension TimerSoundSelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        SoundSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SoundSection(rawValue: section) else { return 0 }
        switch section {
        case .sound:
            return SoundDisplay.allCases.count - 1
        case .none:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = SoundSection(rawValue: section) else { return nil }
        switch section {
        case .sound: return "벨소리"
        case .none: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AlarmSoundSelectionCell.identifier
        ) as? AlarmSoundSelectionCell, let section = SoundSection(
            rawValue: indexPath.section
        ) else {
            return UITableViewCell()
        }

        let sound: SoundDisplay
        switch section {
        case .sound:
            sound = SoundDisplay.allCases[indexPath.row]
        case .none:
            sound = .none
        }

        cell.configure(
            with: sound.title(for: .timer),
            isSelected: viewModel.currentSound.value == sound
        )

        return cell
    }
}

extension TimerSoundSelectionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SoundSection(rawValue: indexPath.section) else { return }

        switch section {
        case .sound:
            viewModel.updatedSound.accept(SoundDisplay.allCases[indexPath.row])
        case .none:
            viewModel.updatedSound.accept(.none)
        }
        selectionView.tableView.reloadData()

        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        cell.contentView.backgroundColor = UIColor.systemGray4

        UIView.animate(withDuration: 0.3) {
            cell.contentView.backgroundColor = UIColor.systemGray5
        }
    }
}
