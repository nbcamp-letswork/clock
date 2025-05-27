//
//  TimerStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

protocol TimerStorage {
    func fetchAll<DomainEntity>(
        _ block: @escaping ([TimerEntity]) -> [DomainEntity],
    ) async -> Result<(ongoing: [DomainEntity], recent: [DomainEntity]), CoreDataError>
    func insert(
        _ block: @escaping (NSManagedObjectContext) -> Void,
    ) async -> Result<Void, CoreDataError>
    func update(
        by id: UUID,
        _ block: @escaping (NSManagedObjectContext, TimerEntity) -> Void,
    ) async -> Result<Void, CoreDataError>
    func delete(by id: UUID) async -> Result<Void, CoreDataError>
}
