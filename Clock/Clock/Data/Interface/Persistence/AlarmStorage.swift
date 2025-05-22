//
//  AlarmStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

protocol AlarmStorage {
    func fetchAlarmGroups<DomainEntity>(
        _ mapped: @escaping (AlarmGroupEntity) -> DomainEntity
    ) async -> Result<[DomainEntity], CoreDataError>
    func insertAlarmGroup(
        _ mapped: @escaping (NSManagedObjectContext) -> AlarmGroupEntity
    ) async -> Result<Void, CoreDataError>
    func updateAlarmGroup(
        predicate: NSPredicate,
        _ updatedAndMapped: @escaping (NSManagedObjectContext, AlarmGroupEntity) -> AlarmGroupEntity
    ) async -> Result<Void, CoreDataError>
    func deleteAlarmGroup(by id: UUID) async -> Result<Void, CoreDataError>
}
