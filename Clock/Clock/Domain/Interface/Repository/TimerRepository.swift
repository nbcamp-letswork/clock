//
//  TimerRepository.swift
//  Clock
//
//  Created by youseokhwan on 5/23/25.
//

import Foundation

protocol TimerRepository {
    func fetchAll() async -> Result<(ongoing: [Timer], recent: [Timer]), Error>
    func create(_ timer: Timer) async -> Result<Void, Error>
    func update(_ timer: Timer) async -> Result<Void, Error>
    func delete(by id: UUID) async -> Result<Void, Error>
}
