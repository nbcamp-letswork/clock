//
//  DummyWidget.swift
//  ClockWidget
//
//  Created by youseokhwan on 5/26/25.
//

import WidgetKit
import SwiftUI

struct DummyProvider: TimelineProvider {
    func placeholder(in context: Context) -> DummyEntry {
        DummyEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (DummyEntry) -> ()) {
        let entry = DummyEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DummyEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = DummyEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DummyEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct DummyWidgetEntryView : View {
    var entry: DummyProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Emoji:")
            Text(entry.emoji)
        }
    }
}

struct DummyWidget: Widget {
    let kind: String = "DummyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DummyProvider()) { entry in
            if #available(iOS 17.0, *) {
                DummyWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DummyWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    DummyWidget()
} timeline: {
    DummyEntry(date: .now, emoji: "😀")
    DummyEntry(date: .now, emoji: "🤩")
}
