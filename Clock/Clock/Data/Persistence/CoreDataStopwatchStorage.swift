//
//  CoreDataStopwatchStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import CoreData

final class CoreDataStopwatchStorage: StopwatchStorage {
    private let container = CoreDataStack.shared.persistentContainer

    func fetch<DomainEntity>(
        _ block: @escaping (StopwatchEntity) -> DomainEntity,
    ) async -> Result<DomainEntity, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = StopwatchEntity.fetchRequest()

                do {
                    guard let entity = try context.fetch(request).first as? StopwatchEntity else {
                        continuation.resume(returning: .failure(.fetchFailed("Type Casting Failed")))
                        return
                    }
                    let stopwatch = block(entity)
                    continuation.resume(returning: .success(stopwatch))
                } catch {
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func insert(
        _ block: @escaping (NSManagedObjectContext) -> Void,
    ) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                block(context)

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
