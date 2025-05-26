//
//  DefaultTimerRepository.swift
//  Clock
//
//  Created by youseokhwan on 5/23/25.
//

import Foundation

final class DefaultTimerRepository: TimerRepository {
    private let storage: TimerStorage

    init(storage: TimerStorage) {
        self.storage = storage
    }

    func fetchAll() async -> Result<(ongoing: [Timer], recent: [Timer]), Error> {
        await storage.fetchAll { [weak self] entity in
            guard let self else { fatalError() }
            return toDomainTimer(entity)
        }.mapError { $0 as Error }
    }

    @discardableResult
    func create(_ timer: Timer) async -> Result<Void, Error> {
        await storage.insert { context in
            let entity = TimerEntity(context: context)
            entity.id = timer.id
            entity.milliseconds = Int64(timer.milliseconds)
            entity.currentMilliseonds = Int64(timer.currentMilliseconds)
            entity.sound = timer.sound.path
            entity.label = timer.label ?? ""
            entity.isRunning = timer.isRunning
            entity.isActive = true
            return entity
        }.mapError { $0 as Error }
    }

    @discardableResult
    func update(_ timer: Timer) async -> Result<Void, Error> {
        await storage.update(by: timer.id) { context, entity in
            entity.milliseconds = Int64(timer.milliseconds)
            entity.currentMilliseonds = Int64(timer.currentMilliseconds)
            entity.sound = timer.sound.path
            entity.label = timer.label ?? ""
            entity.isRunning = timer.isRunning
            return entity
        }.mapError { $0 as Error }
    }

    @discardableResult
    func delete(by id: UUID) async -> Result<Void, Error> {
        await storage.delete(by: id)
            .mapError { $0 as Error }
    }
}

private extension DefaultTimerRepository {
    func toDomainTimer(_ entity: TimerEntity) -> Timer {
        Timer(
            id: entity.id,
            milliseconds: Int(entity.milliseconds),
            isRunning: entity.isRunning,
            currentMilliseconds: Int(entity.currentMilliseonds),
            sound: Sound(path: entity.sound),
            label: entity.label,
        )
    }
}
