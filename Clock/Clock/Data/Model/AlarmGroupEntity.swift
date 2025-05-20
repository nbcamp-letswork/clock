//
//  AlarmGroupEntity.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import CoreData

@objc(AlarmGroup)
public class AlarmGroupEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var order: Int16
    @NSManaged public var alarms: Set<AlarmEntity>?
}
