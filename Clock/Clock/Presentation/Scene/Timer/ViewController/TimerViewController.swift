//
//  TimerViewController.swift
//  Clock
//
//  Created by 이수현 on 5/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TimerViewController: UIViewController {
    private let timerView = TimerView()
    private let viewModel: TimerViewModel
    private let disposeBag = DisposeBag()

    override func loadView() {
        view = timerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setDelegate()
        setDataSource()
        setBindings()
        setNotificationCenter()

        viewModel.viewDidLoad.accept(())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewModel.saveTimers.accept(())
    }

    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveTimers),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    @objc
    func saveTimers() {
        viewModel.saveTimers.accept(())
    }
}

private extension TimerViewController {
    func setNavigationBar() {
        let editButton = BarButtonFactory.customButton(with: "편집")
        let plusButton = BarButtonFactory.plusButton()
        self.navigationItem.setLeftBarButton(editButton, animated: true)
        self.navigationItem.setRightBarButton(plusButton, animated: true)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "타이머"
    }

    func setDelegate() {
        timerView.tableView.delegate = self
    }

    func setDataSource() {
        timerView.tableView.dataSource = self
    }

    func setBindings() {

        // Output Binding
        Observable.combineLatest(viewModel.ongoingTimer, viewModel.recentTimer)
            .observe(on: MainScheduler.instance)
            .do{[weak self] ongoinTimers, _ in
                self?.navigationItem.rightBarButtonItem?.isHidden = ongoinTimers.isEmpty
            }
            .bind {[weak self] ongoingTimers, recentTimers in
                self?.updateTableView(ongoingTimers: ongoingTimers, recentTimers: recentTimers)
            }.disposed(by: disposeBag)

        viewModel.error
            .bind { error in
                //TODO: Error 처리
            }.disposed(by: disposeBag)
    }

    func updateTableView(ongoingTimers: [TimerDisplay], recentTimers: [TimerDisplay]) {
        let ongoingSection = TimerSectionType.ongoingTimer.rawValue
        let recentSection = TimerSectionType.recentTimer.rawValue
        let exsitingOngingTimerCount = timerView.tableView.numberOfRows(inSection: ongoingSection)
        let exsitingRecentTimerCount = timerView.tableView.numberOfRows(inSection: recentSection)

        if ongoingTimers.count != exsitingOngingTimerCount || recentTimers.count != exsitingRecentTimerCount {
            timerView.tableView.reloadData()
        } else {
            guard let indexPaths = timerView.tableView.indexPathsForVisibleRows?
                .filter({ $0.section == 0 }) else {
                return
            }
            for indexPath in indexPaths {
                let cell = timerView.tableView.cellForRow(at: indexPath)
                (cell as? OngoingTimerCell)?.configure(timer: ongoingTimers[indexPath.row])
            }
        }
    }
}

extension TimerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return TimerSectionType.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TimerSectionType(rawValue: section) {
        case .ongoingTimer:
            return viewModel.ongoingTimer.value.count
        case .recentTimer:
            return viewModel.recentTimer.value.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TimerSectionType(rawValue: indexPath.section) {
        case .ongoingTimer:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: OngoingTimerCell.identifier
            ) as? OngoingTimerCell else {
                return UITableViewCell()
            }
            let data = viewModel.ongoingTimer.value[indexPath.row]
            cell.configure(timer: data)
            cell.controlButton.rx.tap
                .withLatestFrom(Observable.just(data.id))
                .bind(to: viewModel.toggleOrAddTimer)
                .disposed(by: cell.disposeBag)
            return cell
        case .recentTimer:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: RecentTimerCell.identifier
            ) as? RecentTimerCell else {
                return UITableViewCell()
            }
            let data = viewModel.recentTimer.value[indexPath.row]
            cell.configure(timer: data)
            cell.controlButton.rx.tap
                .withLatestFrom(Observable.just(data.id))
                .bind(to: viewModel.toggleOrAddTimer)
                .disposed(by: cell.disposeBag)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension TimerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch TimerSectionType(rawValue: section) {
        case .ongoingTimer:
            guard viewModel.ongoingTimer.value.isEmpty else { return nil }
            let header = OngoingTimerHeaderView()
            header.startButton.rx.tap
                .withLatestFrom(header.createdTimer.compactMap{$0})
                .bind {[weak self] time, sound, label in
                    header.endEditing(true)
                    self?.viewModel.createTimer.accept((time, sound, label))
                }.disposed(by: header.disposeBag)

            return header
        case .recentTimer:
            return RecentTimerHeaderView()
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch TimerSectionType(rawValue: section) {
        case .ongoingTimer:
            return viewModel.ongoingTimer.value.isEmpty ? UITableView.automaticDimension : 0
        case .recentTimer:
            return 44
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        viewModel.deleteTimer.accept(indexPath)
    }
}
