//
//  CoreDataTimerStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

final class CoreDataTimerStorage: TimerStorage {
    private let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "TimerModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData Error: \(error)")
            }
        }
    }

    func fetchAll<DomainEntity>(
        _ mapped: @escaping ([TimerEntity]) -> [DomainEntity],
    ) async -> Result<(ongoing: [DomainEntity], recent: [DomainEntity]), CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = TimerEntity.fetchRequest()

                do {
                    guard let entities = try context.fetch(request) as? [TimerEntity] else {
                        continuation.resume(returning: .failure(.fetchFailed("Type Casting Failed")))
                        return
                    }
                    let ongoing = mapped(entities.filter { $0.isActive })
                    let recent = mapped(entities.filter { !$0.isActive })

                    continuation.resume(returning: .success((ongoing: ongoing, recent: recent)))
                } catch {
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func insert(
        _ mapped: @escaping (NSManagedObjectContext) -> TimerEntity
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

    @discardableResult
    func update(
        by id: UUID,
        _ updatedAndMapped: @escaping (NSManagedObjectContext, TimerEntity) -> TimerEntity
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
                    _ = updatedAndMapped(context, original)

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
