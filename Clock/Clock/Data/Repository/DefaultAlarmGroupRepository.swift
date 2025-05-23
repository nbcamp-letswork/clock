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
        let result = await storage.fetchAlarmGroups { [weak self] entity in
            guard let self else { fatalError("deallocated") }
            return toDomainAlarmGroup(entity)
        }

        switch result {
        case .success(let entities):
            return .success(entities)
        case .failure(let error):
            return .failure(error)
        }
    }

    @discardableResult
    func create(_ alarmGroup: AlarmGroup) async -> Result<Void, Error> {
        let result = await storage.insertAlarmGroup { context in
            let entity = AlarmGroupEntity(context: context)
            entity.id = alarmGroup.id
            entity.name = alarmGroup.name
            entity.order = Int16(alarmGroup.order)
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
    func update(_ alarmGroup: AlarmGroup) async -> Result<Void, Error> {
        let result = await storage.updateAlarmGroup(by: alarmGroup.id) { context, entity in
            entity.name = alarmGroup.name
            entity.order = Int16(alarmGroup.order)
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
        let result = await storage.deleteAlarmGroup(by: id)

        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}

private extension DefaultAlarmGroupRepository {
    func toDomainAlarmGroup(_ entity: AlarmGroupEntity) -> AlarmGroup {
        AlarmGroup(
            id: entity.id,
            name: entity.name,
            order: Int(entity.order),
            alarms: toDomainAlarms(entity.alarms),
        )
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
