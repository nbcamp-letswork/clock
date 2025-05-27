//
//  TimerStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

protocol TimerStorage {
    func fetchAll<DomainEntity>(
        _ mapped: @escaping ([TimerEntity]) -> [DomainEntity],
    ) async -> Result<(ongoing: [DomainEntity], recent: [DomainEntity]), CoreDataError>
    func insert(
        _ mapped: @escaping (NSManagedObjectContext) -> Void,
    ) async -> Result<Void, CoreDataError>
    func update(
        by id: UUID,
        _ updatedAndMapped: @escaping (NSManagedObjectContext, TimerEntity) -> Void,
    ) async -> Result<Void, CoreDataError>
    func delete(by id: UUID) async -> Result<Void, CoreDataError>
}
