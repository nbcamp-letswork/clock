//
//  CoreDataAlarmStorage+Extensions.swift
//  Clock
//
//  Created by youseokhwan on 5/27/25.
//

import CoreData

extension CoreDataAlarmStorage {
    func fetchNextAlarm() -> Date? {
        let context = container.viewContext
        let request = AlarmEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isEnabled == YES")

        do {
            guard let alarms = try context.fetch(request) as? [AlarmEntity] else { return nil }
            let now = Date()
            let calendar = Calendar.current

            let nextAlarmDates: [Date] = alarms.compactMap { alarm in
                if let repeatDays = alarm.repeatDays, !repeatDays.isEmpty {
                    let nextDates = repeatDays.compactMap { repeatDay -> Date? in
                        let weekday = Int(repeatDay.weekday)
                        var nextDateComponents = calendar.dateComponents(
                            [.yearForWeekOfYear, .weekOfYear],
                            from: now,
                        )
                        nextDateComponents.weekday = weekday
                        nextDateComponents.hour = Int(alarm.hour)
                        nextDateComponents.minute = Int(alarm.minute)

                        guard var candidateDate = calendar.nextDate(
                            after: now,
                            matching: nextDateComponents,
                            matchingPolicy: .nextTimePreservingSmallerComponents,
                        ) else { return nil }

                        if calendar.isDate(candidateDate, inSameDayAs: now), candidateDate < now {
                            candidateDate = calendar.date(byAdding: .day, value: 7, to: candidateDate)!
                        }

                        return candidateDate
                    }

                    return nextDates.min()
                } else {
                    var components = calendar.dateComponents(
                        [.year, .month, .day],
                        from: now,
                    )
                    components.hour = Int(alarm.hour)
                    components.minute = Int(alarm.minute)

                    if let alarmDate = calendar.date(from: components) {
                        return alarmDate > now ? alarmDate : calendar.date(byAdding: .day, value: 1, to: alarmDate)
                    }
                    return nil
                }
            }

            return nextAlarmDates.min()
        } catch {
            print("Failed to fetch alarms: \(error)")
            return nil
        }
    }
}
