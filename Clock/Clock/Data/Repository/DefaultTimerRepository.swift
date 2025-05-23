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

    func fetchAll() async -> Result<[Timer], Error> {
        let result = await storage.fetchAll { [weak self] entity in
            guard let self else { fatalError() }
            return toDomainTimer(entity)
        }

        switch result {
        case .success(let entities):
            return .success(entities)
        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func create(_ timer: Timer) async -> Result<Void, Error> {
        let result = await storage.insert { context in
            let entity = TimerEntity(context: context)
            entity.id = timer.id
            entity.milliseconds = Int64(timer.milliseconds)
            entity.currentMilliseonds = Int64(timer.currentMilliseconds)
            entity.sound = timer.sound.path
            entity.label = timer.label ?? ""
            return entity
        }

        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func update(_ timer: Timer) async -> Result<Void, Error> {
        let result = await storage.update(by: timer.id) { context, entity in
            entity.milliseconds = Int64(timer.milliseconds)
            entity.currentMilliseonds = Int64(timer.currentMilliseconds)
            entity.sound = timer.sound.path
            entity.label = timer.label ?? ""
            return entity
        }

        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func delete(by id: UUID) async -> Result<Void, Error> {
        let result = await storage.delete(by: id)

        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}

private extension DefaultTimerRepository {
    func toDomainTimer(_ entity: TimerEntity) -> Timer {
        Timer(
            id: entity.id,
            milliseconds: Int(entity.milliseconds),
            currentMilliseconds: Int(entity.currentMilliseonds),
            sound: Sound(path: entity.sound),
            label: entity.label,
        )
    }
}
