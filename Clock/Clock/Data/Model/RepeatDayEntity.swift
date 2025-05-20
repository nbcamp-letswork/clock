//
//  RepeatDayEntity.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

@objc(RepeatDay)
public class RepeatDayEntity: NSManagedObject {
    @NSManaged public var weekday: Int16
    @NSManaged public var alarm: AlarmEntity?
}
