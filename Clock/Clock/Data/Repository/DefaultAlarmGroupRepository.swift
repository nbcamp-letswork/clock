//
//  DefaultAlarmGroupRepository.swift
//  Clock
//
//  Created by youseokhwan on 5/23/25.
//

import Foundation

final class DefaultAlarmGroupRepository: AlarmGroupRepository {
    private let storage: AlarmStorage

    init(storage: AlarmStorage) {
        self.storage = storage
    }

    func fetchAll() async -> Result<[AlarmGroup], Error> {
        await storage.fetchAlarmGroups { [weak self] entities in
            guard let self else { fatalError("deallocated") }
            return toDomainAlarmGroups(entities)
        }.mapError { $0 as Error }
    }

    @discardableResult
    func create(_ alarmGroup: AlarmGroup) async -> Result<Void, Error> {
        await storage.insertAlarmGroup { context in
            let entity = AlarmGroupEntity(context: context)
            entity.id = alarmGroup.id
            entity.name = alarmGroup.name
            entity.order = Int16(alarmGroup.order)
        }.mapError { $0 as Error }
    }

    @discardableResult
    func update(_ alarmGroup: AlarmGroup) async -> Result<Void, Error> {
        await storage.updateAlarmGroup(by: alarmGroup.id) { context, entity in
            entity.name = alarmGroup.name
            entity.order = Int16(alarmGroup.order)
        }.mapError { $0 as Error }
    }

    @discardableResult
    func delete(by id: UUID) async -> Result<Void, Error> {
        await storage.deleteAlarmGroup(by: id)
            .mapError { $0 as Error }
    }

    func exists(by id: UUID) async -> Result<Bool, Error> {
        await storage.existsAlarmGroup(by: id)
            .mapError { $0 as Error }
    }
}

private extension DefaultAlarmGroupRepository {
    func toDomainAlarmGroups(_ entities: [AlarmGroupEntity]) -> [AlarmGroup] {
        entities.map {
            AlarmGroup(
                id: $0.id,
                name: $0.name,
                order: Int($0.order),
                alarms: toDomainAlarms($0.alarms),
            )
        }
    }

    func toDomainAlarms(_ entities: Set<AlarmEntity>?) -> [Alarm] {
        (entities ?? []).map {
            Alarm(
                id: $0.id,
                hour: Int($0.hour),
                minute: Int($0.minute),
                label: $0.label,
                sound: Sound(path: $0.sound),
                isSnooze: $0.isSnooze,
                isEnabled: $0.isEnabled,
                repeatDays: toDomainRepeatDays($0.repeatDays),
            )
        }
    }

    func toDomainRepeatDays(_ entities: Set<RepeatDayEntity>?) -> [RepeatDay] {
        (entities ?? []).map {
            RepeatDay(weekday: Int($0.weekday))
        }
    }
}
