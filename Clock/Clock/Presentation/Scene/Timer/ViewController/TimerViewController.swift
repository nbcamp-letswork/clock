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
        bindViewModel()

        viewModel.viewDidLoad.accept(())
    }

    private func bindViewModel() {

        Observable.combineLatest(viewModel.ongoingTimer, viewModel.recentTimer)
            .observe(on: MainScheduler.instance)
            .bind {[weak self] _, _ in
                self?.timerView.tableView.reloadData()
            }.disposed(by: disposeBag)

        viewModel.error
            .bind { error in
                //TODO: Error 처리
            }.disposed(by: disposeBag)
    }

    init(viewModel: TimerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TimerViewController {
    func setNavigationBar() {
        let editButton = BarButtonFactory.editButton()
        self.navigationItem.setLeftBarButton(editButton, animated: true)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "타이머"
    }

    func setDelegate() {
        timerView.tableView.delegate = self
    }

    func setDataSource() {
        timerView.tableView.dataSource = self
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
            cell.configure(timer: viewModel.ongoingTimer.value[indexPath.row])
            return cell
        case .recentTimer:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: RecentTimerCell.identifier
            ) as? RecentTimerCell else {
                return UITableViewCell()
            }
            cell.configure(timer: viewModel.recentTimer.value[indexPath.row])
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
            return viewModel.ongoingTimer.value.isEmpty ? OngoingTimerHeaderView() : nil
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
}
