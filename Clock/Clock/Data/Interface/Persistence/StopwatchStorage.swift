//
//  StopwatchStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import CoreData

protocol StopwatchStorage {
    func fetch<DomainEntity>(
        _ mapped: @escaping (StopwatchEntity) -> DomainEntity
    ) async -> Result<DomainEntity, CoreDataError>
    func insert(
        _ mapped: @escaping (NSManagedObjectContext) -> StopwatchEntity
    ) async -> Result<Void, CoreDataError>
    func delete() async -> Result<Void, CoreDataError>
}
