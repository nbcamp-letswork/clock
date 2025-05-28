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
        _ mapped: @escaping (AlarmGroupEntity) -> DomainEntity
    ) async -> Result<[DomainEntity], CoreDataError>
    func insertAlarmGroup(
        _ mapped: @escaping (NSManagedObjectContext) -> AlarmGroupEntity
    ) async -> Result<Void, CoreDataError>
    func updateAlarmGroup(
        by id: UUID,
        _ updatedAndMapped: @escaping (NSManagedObjectContext, AlarmGroupEntity) -> AlarmGroupEntity
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
        _ mapped: @escaping (NSManagedObjectContext, AlarmGroupEntity) -> AlarmEntity
    ) async -> Result<Void, CoreDataError>
    func updateAlarm(
        by id: UUID,
        _ updatedAndMapped: @escaping (NSManagedObjectContext, AlarmEntity) -> AlarmEntity
    ) async -> Result<Void, CoreDataError>
    func deleteAlarm(by id: UUID) async -> Result<Void, CoreDataError>
}
