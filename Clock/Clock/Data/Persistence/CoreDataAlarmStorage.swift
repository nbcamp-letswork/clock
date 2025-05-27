//
//  CoreDataAlarmStorage.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

final class CoreDataAlarmStorage: AlarmStorage {
    private(set) var container = CoreDataStack.shared.persistentContainer

    // MARK: - AlarmGroupEntity

    func fetchAlarmGroups<DomainEntity>(
        _ block: @escaping ([AlarmGroupEntity]) -> [DomainEntity],
    ) async -> Result<[DomainEntity], CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmGroupEntity.fetchRequest()

                do {
                    guard let entities = try context.fetch(request) as? [AlarmGroupEntity] else {
                        continuation.resume(returning: .failure(.fetchFailed("Type Casting Failed")))
                        return
                    }
                    let alarmGroups = block(entities)
                    continuation.resume(returning: .success(alarmGroups))
                } catch {
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func insertAlarmGroup(
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
    func updateAlarmGroup(
        by id: UUID,
        _ block: @escaping (NSManagedObjectContext, AlarmGroupEntity) -> Void,
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
        with id: UUID,
        _ block: @escaping (AlarmEntity) -> DomainEntity,
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

                    let alarm = block(entity)
                    continuation.resume(returning: .success(alarm))
                } catch {
                    continuation.resume(returning: .failure(.fetchFailed(error.localizedDescription)))
                }
            }
        }
    }

    @discardableResult
    func insertAlarm(
        into groupID: UUID,
        _ block: @escaping (NSManagedObjectContext, AlarmGroupEntity) -> Void,
    ) async -> Result<Void, CoreDataError> {
        await withCheckedContinuation { continuation in
            container.performBackgroundTask { context in
                let request = AlarmGroupEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", groupID as CVarArg)

                do {
                    guard let entity = try context.fetch(request).first as? AlarmGroupEntity else {
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }
                    block(context, entity)

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
        _ block: @escaping (NSManagedObjectContext, AlarmEntity) -> Void,
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
