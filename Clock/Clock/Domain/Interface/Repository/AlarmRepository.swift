//
//  AlarmRepository.swift
//  Clock
//
//  Created by youseokhwan on 5/23/25.
//

import Foundation

protocol AlarmRepository {
    func create(_ alarm: Alarm, into groupID: UUID) async -> Result<Void, Error>
    func update(_ alarm: Alarm) async -> Result<Void, Error>
    func delete(by id: UUID) async -> Result<Void, Error>
}
