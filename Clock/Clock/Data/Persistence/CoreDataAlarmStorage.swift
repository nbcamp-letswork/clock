//
//  CoreDataAlarmStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

final class CoreDataAlarmStorage: AlarmStorage {
    private let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "AlarmModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData Error: \(error)")
            }
        }
    }

    func fetchAlarmGroups<DomainEntity>(
        _ mapped: @escaping (AlarmGroupEntity) -> DomainEntity,
    ) async -> Result<[DomainEntity], CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmGroupEntity.fetchRequest()
                do {
                    guard let entities = try context.fetch(request) as? [AlarmGroupEntity] else {
                        continuation.resume(returning: .failure(.fetchFailed("Type Casting Failed")))
                        return
                    }
                    let mapped = entities.map(mapped)
                    continuation.resume(returning: .success(mapped))
                } catch {
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func insertAlarmGroup(
        _ mapped: @escaping (NSManagedObjectContext) -> AlarmGroupEntity,
    ) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                _ = mapped(context)
                do {
                    try context.save()
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.insertFailed(error.localizedDescription)))
                }
            }
        }
    }
}
