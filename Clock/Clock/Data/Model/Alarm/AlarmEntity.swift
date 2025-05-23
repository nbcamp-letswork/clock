//
//  AlarmEntity.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

@objc(Alarm)
public class AlarmEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var hour: Int16
    @NSManaged public var minute: Int16
    @NSManaged public var label: String
    @NSManaged public var sound: String
    @NSManaged public var isSnooze: Bool
    @NSManaged public var isEnabled: Bool
    @NSManaged public var repeatDays: Set<RepeatDayEntity>?
    @NSManaged public var alarmGroup: AlarmGroupEntity?
}
