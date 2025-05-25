import Foundation

struct AlarmMapper {
    func mapToAlarmGroupDisplay(_ group: AlarmGroup) -> AlarmGroupDisplay {
        AlarmGroupDisplay(
            id: group.id,
            name: group.name,
            order: group.order,
            alarms: group.alarms.map { mapToAlarmDisplay($0) }
        )
    }

    private func mapToAlarmDisplay(_ alarm: Alarm) -> AlarmDisplay {
        AlarmDisplay(
            id: alarm.id,
            time: mapToAlarmTimeDisplay(alarm.hour, alarm.minute),
            label: mapToAlarmLabelDisplay(alarm.label),
            sound: mapToSoundDisplay(alarm.sound),
            isSnooze: alarm.isSnooze,
            isEnabled: alarm.isEnabled,
            repeatDays: mapToRepeatDaysDisplay(alarm.repeatDays)
        )
    }

    private func mapToAlarmTimeDisplay(_ hour: Int, _ minute: Int) -> AlarmTimeDisplay {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let time = Calendar.current.date(from: components)!

        return AlarmTimeDisplay(raw: time)
    }

    private func mapToAlarmLabelDisplay(_ label: String) -> AlarmLabelDisplay {
        .init(raw: label)
    }

    private func mapToSoundDisplay(_ sound: Sound) -> SoundDisplay {
        switch sound {
        case .bell: return .bell
        case .none: return .none
        }
    }

    private func mapToRepeatDaysDisplay(_ repeatDays: [RepeatDay]) -> AlarmRepeatDaysDisplay {
        AlarmRepeatDaysDisplay(raw: repeatDays.map { $0.weekday })
    }

    func mapToAlarmGroup(_ group: AlarmGroupDisplay) -> AlarmGroup {
        AlarmGroup(
            id: group.id,
            name: group.name,
            order: group.order,
            alarms: []
        )
    }

    func mapToAlarm(_ alarm: AlarmDisplay) -> Alarm {
        let (hour, minute) = mapToAlarmTime(alarm.time.raw)

        return Alarm(
            id: alarm.id,
            hour: hour,
            minute: minute,
            label: alarm.label.raw,
            sound: mapToSound(alarm.sound),
            isSnooze: alarm.isSnooze,
            isEnabled: alarm.isEnabled,
            repeatDays: mapToRepeatDays(alarm.repeatDays)
        )
    }

    private func mapToAlarmTime(_ time: Date) -> (Int, Int) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        return (hour, minute)
    }

    private func mapToSound(_ sound: SoundDisplay) -> Sound {
        switch sound {
        case .bell: return .bell
        case .none: return .none
        }
    }

    private func mapToRepeatDays(_ repeatDays: AlarmRepeatDaysDisplay) -> [RepeatDay] {
        repeatDays.raw.map { RepeatDay(weekday: $0) }
    }
}
