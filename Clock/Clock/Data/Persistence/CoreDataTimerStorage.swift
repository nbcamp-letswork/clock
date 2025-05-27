//
//  CoreDataTimerStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

final class CoreDataTimerStorage: TimerStorage {
    private let container = CoreDataStack.shared.persistentContainer

    func fetchAll<DomainEntity>(
        _ block: @escaping ([TimerEntity]) -> [DomainEntity],
    ) async -> Result<(ongoing: [DomainEntity], recent: [DomainEntity]), CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = TimerEntity.fetchRequest()

                do {
                    guard let entities = try context.fetch(request) as? [TimerEntity] else {
                        continuation.resume(returning: .failure(.fetchFailed("Type Casting Failed")))
                        return
                    }
                    let ongoing = block(entities.filter { $0.isActive })
                    let recent = block(entities.filter { !$0.isActive })

                    continuation.resume(returning: .success((ongoing: ongoing, recent: recent)))
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
    func update(
        by id: UUID,
        _ block: @escaping (NSManagedObjectContext, TimerEntity) -> Void,
    ) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = TimerEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                do {
                    guard let original = try context.fetch(request).first as? TimerEntity else {
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }
                    block(context, original)

                    try context.save()
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.updateFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func delete(by id: UUID) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = TimerEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                do {
                    guard let entity = try context.fetch(request).first as? TimerEntity else {
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
