//
//  CoreDataStopwatchStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import CoreData

final class CoreDataStopwatchStorage: StopwatchStorage {
    private let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "StopwatchModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData Error: \(error)")
            }
        }
    }

    func fetch<DomainEntity>(
        _ mapped: @escaping (StopwatchEntity) -> DomainEntity,
    ) async -> Result<DomainEntity, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = StopwatchEntity.fetchRequest()

                do {
                    guard let entity = try context.fetch(request).first as? StopwatchEntity else {
                        continuation.resume(returning: .failure(.fetchFailed("Type Casting Failed")))
                        return
                    }
                    let mapped = mapped(entity)
                    continuation.resume(returning: .success(mapped))
                } catch {
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func insert(
        _ mapped: @escaping (NSManagedObjectContext) -> Void,
    ) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                mapped(context)

                do {
                    try context.save()
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.insertFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func delete() async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = StopwatchEntity.fetchRequest()

                do {
                    guard let entity = try context.fetch(request).first as? StopwatchEntity else {
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }

                    context.delete(entity)
                    try context.save()
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.deleteFailed(error.localizedDescription)))
                }
            }
        }
    }
}
