//
//  DefaultStopwatchRepository.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import Foundation

final class DefaultStopwatchRepository: StopwatchRepository {
    private let storage: StopwatchStorage

    init(storage: StopwatchStorage) {
        self.storage = storage
    }

    func fetch() async -> Result<Stopwatch, Error> {
        await storage.fetch { [weak self] entity in
            guard let self else { fatalError("deallocated") }
            return toDomainStopwatch(entity)
        }.mapError { $0 as Error }
    }

    func save(_ stopwatch: Stopwatch) async -> Result<Void, Error> {
        await storage.insert { context in
            let entity = StopwatchEntity(context: context)
            entity.isRunning = stopwatch.isRunning
            entity.laps = Set(stopwatch.laps.map {
                let lapEntity = LapEntity(context: context)
                lapEntity.lapNumber = Int16($0.lapNumber)
                lapEntity.time = $0.time
                lapEntity.stopwatch = entity
                return lapEntity
            })
            return entity
        }.mapError { $0 as Error }
    }

    func delete() async -> Result<Void, Error> {
        await storage.delete()
            .mapError { $0 as Error }
    }
}

private extension DefaultStopwatchRepository {
    func toDomainStopwatch(_ entity: StopwatchEntity) -> Stopwatch {
        Stopwatch(
            isRunning: entity.isRunning,
            laps: toDomainLaps(entity.laps),
        )
    }

    func toDomainLaps(_ entities: Set<LapEntity>?) -> [Lap] {
        (entities ?? []).map {
            Lap(
                lapNumber: Int($0.lapNumber),
                time: $0.time,
            )
        }
    }
}
