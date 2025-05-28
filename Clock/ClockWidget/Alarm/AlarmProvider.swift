//
//  AlarmProvider.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import WidgetKit

struct AlarmProvider: TimelineProvider {
    private let storage = CoreDataAlarmStorage()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    func placeholder(in context: Context) -> AlarmEntry {
        AlarmEntry(date: Date(), nextAlarmString: "--:--")
    }

    func getSnapshot(in context: Context, completion: @escaping (AlarmEntry) -> Void) {
        Task {
            let nextAlarmDate = await storage.fetchNextAlarm()
            let nextAlarmString = nextAlarmDate.map { dateFormatter.string(from: $0) } ?? "--:--"
            let entry = AlarmEntry(date: Date(), nextAlarmString: nextAlarmString)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let now = Date()
            let nextAlarmDate = await storage.fetchNextAlarm()
            let nextAlarmString = nextAlarmDate.map {
                dateFormatter.string(from: $0)
            } ?? "--:--"

            let entry = AlarmEntry(date: Date(), nextAlarmString: nextAlarmString)
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: now)!
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))

            completion(timeline)
        }
    }
}
