//
//  AlarmGroupRepository.swift
//  Clock
//
//  Created by youseokhwan on 5/23/25.
//

import Foundation

protocol AlarmGroupRepository {
    func fetchAll() async -> Result<[AlarmGroup], Error>
    func create(_ alarmGroup: AlarmGroup) async -> Result<Void, Error>
    func update(_ alarmGroup: AlarmGroup) async -> Result<Void, Error>
    func delete(by id: UUID) async -> Result<Void, Error>
    func exists(by id: UUID) async -> Result<Bool, Error>
}
