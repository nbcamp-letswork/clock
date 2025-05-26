//
//  AlarmProvider.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import WidgetKit

struct AlarmProvider: TimelineProvider {
    func placeholder(in context: Context) -> AlarmEntry {
        AlarmEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (AlarmEntry) -> Void) {
        let entry = AlarmEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entries = [AlarmEntry]()
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
