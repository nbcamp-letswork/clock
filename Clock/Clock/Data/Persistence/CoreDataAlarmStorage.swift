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

    // MARK: - AlarmGroupEntity

    func fetchAlarmGroups<DomainEntity>(
        _ mapped: @escaping ([AlarmGroupEntity]) -> [DomainEntity],
    ) async -> Result<[DomainEntity], CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmGroupEntity.fetchRequest()

                do {
                    guard let entities = try context.fetch(request) as? [AlarmGroupEntity] else {
                        continuation.resume(returning: .failure(.fetchFailed("Type Casting Failed")))
                        return
                    }
                    let mapped = mapped(entities)
                    continuation.resume(returning: .success(mapped))
                } catch {
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func insertAlarmGroup(
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
    func updateAlarmGroup(
        by id: UUID,
        _ updatedAndMapped: @escaping (NSManagedObjectContext, AlarmGroupEntity) -> Void,
    ) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmGroupEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                do {
                    guard let original = try context.fetch(request).first as? AlarmGroupEntity else {
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }
                    updatedAndMapped(context, original)

                    try context.save()
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.updateFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func deleteAlarmGroup(by id: UUID) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmGroupEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                do {
                    guard let entity = try context.fetch(request).first as? AlarmGroupEntity else {
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

    func existsAlarmGroup(by id: UUID) async -> Result<Bool, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmGroupEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                request.fetchLimit = 1

                do {
                    let count = try context.count(for: request)
                    continuation.resume(returning: .success(count > 0))
                } catch {
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    // MARK: - AlarmEntity

    func fetchAlarm<DomainEntity>(
        id: UUID,
        mapped: @escaping (AlarmEntity) -> DomainEntity
    ) async -> Result<DomainEntity, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                request.fetchLimit = 1

                do {
                    guard let entity = try context.fetch(request).first as? AlarmEntity else {
                        continuation.resume(returning: .failure(.fetchFailed("No AlarmEntity found with id \(id)")))
                        return
                    }

                    let domainModel = mapped(entity)
                    continuation.resume(returning: .success(domainModel))
                } catch {
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func insertAlarm(
        into groupID: UUID,
        _ mapped: @escaping (NSManagedObjectContext, AlarmGroupEntity) -> Void,
    ) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmGroupEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", groupID as CVarArg)

                do {
                    guard let groupEntity = try context.fetch(request).first as? AlarmGroupEntity else {
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }
                    mapped(context, groupEntity)

                    try context.save()
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.insertFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func updateAlarm(
        by id: UUID,
        _ updatedAndMapped: @escaping (NSManagedObjectContext, AlarmEntity) -> Void,
    ) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                do {
                    guard let original = try context.fetch(request).first as? AlarmEntity else {
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }
                    updatedAndMapped(context, original)

                    try context.save()
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.updateFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func deleteAlarm(by id: UUID) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                do {
                    guard let entity = try context.fetch(request).first as? AlarmEntity else {
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
