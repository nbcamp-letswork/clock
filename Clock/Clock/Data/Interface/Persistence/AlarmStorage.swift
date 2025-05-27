//
//  AlarmStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

protocol AlarmStorage {
    // MARK: - AlarmGroupEntity

    func fetchAlarmGroups<DomainEntity>(
        _ block: @escaping ([AlarmGroupEntity]) -> [DomainEntity]
    ) async -> Result<[DomainEntity], CoreDataError>
    func insertAlarmGroup(
        _ block: @escaping (NSManagedObjectContext) -> Void,
    ) async -> Result<Void, CoreDataError>
    func updateAlarmGroup(
        by id: UUID,
        _ block: @escaping (NSManagedObjectContext, AlarmGroupEntity) -> Void,
    ) async -> Result<Void, CoreDataError>
    func deleteAlarmGroup(by id: UUID) async -> Result<Void, CoreDataError>
    func existsAlarmGroup(by id: UUID) async -> Result<Bool, CoreDataError>

    // MARK: - AlarmEntity

    func fetchAlarm<DomainEntity>(
        id: UUID,
        mapped: @escaping (AlarmEntity) -> DomainEntity
    ) async -> Result<DomainEntity, CoreDataError>
    func insertAlarm(
        into groupID: UUID,
        _ block: @escaping (NSManagedObjectContext, AlarmGroupEntity) -> Void,
    ) async -> Result<Void, CoreDataError>
    func updateAlarm(
        by id: UUID,
        _ block: @escaping (NSManagedObjectContext, AlarmEntity) -> Void,
    ) async -> Result<Void, CoreDataError>
    func deleteAlarm(by id: UUID) async -> Result<Void, CoreDataError>
}
