//
//  StopwatchViewController.swift
//  Clock
//
//  Created by 유현진 on 5/21/25.
//

import UIKit

final class StopwatchViewController: UIViewController {
    private let stopwatchView = StopwatchView()
    
    override func loadView() {
        view = stopwatchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
}
