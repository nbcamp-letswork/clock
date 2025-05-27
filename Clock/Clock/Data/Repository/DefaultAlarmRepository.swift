//
//  DefaultAlarmRepository.swift
//  Clock
//
//  Created by youseokhwan on 5/23/25.
//

import Foundation

final class DefaultAlarmRepository: AlarmRepository {
    private let storage: AlarmStorage

    init(storage: AlarmStorage) {
        self.storage = storage
    }

    func fetch(_ id: UUID) async -> Result<Alarm, Error> {
        await storage.fetchAlarm(id: id) { [weak self] entity in
            guard let self else { fatalError("deallocated") }
            return toDomainAlarm(entity)
        }.mapError { $0 as Error }
    }

    @discardableResult
    func create(_ alarm: Alarm, into groupID: UUID) async -> Result<Void, Error> {
        await storage.insertAlarm(into: groupID) { context, groupEntity in
            let alarmEntity = AlarmEntity(context: context)
            alarmEntity.id = alarm.id
            alarmEntity.hour = Int16(alarm.hour)
            alarmEntity.minute = Int16(alarm.minute)
            alarmEntity.label = alarm.label
            alarmEntity.sound = alarm.sound.path
            alarmEntity.isSnooze = alarm.isSnooze
            alarmEntity.isEnabled = alarm.isEnabled
            for repeatDay in alarm.repeatDays {
                let repeatDayEntity = RepeatDayEntity(context: context)
                repeatDayEntity.weekday = Int16(repeatDay.weekday)
                repeatDayEntity.alarm = alarmEntity
                alarmEntity.repeatDays?.insert(repeatDayEntity)
            }
            alarmEntity.alarmGroup = groupEntity
        }.mapError { $0 as Error }
    }

    @discardableResult
    func update(_ alarm: Alarm) async -> Result<Void, Error> {
        await storage.updateAlarm(by: alarm.id) { context, entity in
            entity.id = alarm.id
            entity.hour = Int16(alarm.hour)
            entity.minute = Int16(alarm.minute)
            entity.label = alarm.label
            entity.sound = alarm.sound.path
            entity.isSnooze = alarm.isSnooze
            entity.isEnabled = alarm.isEnabled
            if let repeatDaysEntities = entity.repeatDays {
                for repeatDayEntity in repeatDaysEntities {
                    context.delete(repeatDayEntity)
                }
            }
            for repeatDay in alarm.repeatDays {
                let repeatDayEntity = RepeatDayEntity(context: context)
                repeatDayEntity.weekday = Int16(repeatDay.weekday)
                repeatDayEntity.alarm = entity
                entity.repeatDays?.insert(repeatDayEntity)
            }
        }.mapError { $0 as Error }
    }

    @discardableResult
    func delete(by id: UUID) async -> Result<Void, Error> {
        await storage.deleteAlarm(by: id)
            .mapError { $0 as Error }
    }
}

extension DefaultAlarmRepository {
    func toDomainAlarm(_ entities: AlarmEntity) -> Alarm {
        Alarm(
            id: entities.id,
            hour: Int(entities.hour),
            minute: Int(entities.minute),
            label: entities.label,
            sound: Sound(path: entities.sound),
            isSnooze: entities.isSnooze,
            isEnabled: entities.isEnabled,
            repeatDays: toDomainRepeatDays(entities.repeatDays),
        )
    }

    func toDomainRepeatDays(_ entities: Set<RepeatDayEntity>?) -> [RepeatDay] {
        (entities ?? []).map {
            RepeatDay(weekday: Int($0.weekday))
        }
    }
}
