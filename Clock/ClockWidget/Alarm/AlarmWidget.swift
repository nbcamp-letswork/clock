//
//  AlarmWidget.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import WidgetKit
import SwiftUI

struct AlarmWidget: Widget {
    let kind = "AlarmWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: AlarmProvider(),
        ) { entry in
            AlarmView(entry: entry)
        }
        .configurationDisplayName("Next Alarm")
        .description("다음 알람을 표시합니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct AlarmView: View {
    var entry: AlarmProvider.Entry

    var body: some View {
        if #available(iOS 17.0, *) {
            VStack(alignment: .leading, spacing: 8) {
                Text("다음 알람")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(entry.nextAlarmString)
                    .font(.largeTitle)
                    .foregroundStyle(.foreground)
            }
            .containerBackground(for: .widget) {
                Color.clear
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("다음 알람")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(entry.nextAlarmString)
                    .font(.largeTitle)
                    .foregroundStyle(.foreground)
            }
        }
    }
}
