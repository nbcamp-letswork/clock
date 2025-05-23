//
//  TimerEntity.swift
//  Clock
//
//  Created by youseokhwan on 5/23/25.
//

import CoreData

@objc(Timer)
public class TimerEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var milliseconds: Int64
    @NSManaged public var currentMilliseonds: Int64
    @NSManaged public var label: String
    @NSManaged public var sound: String
    @NSManaged public var isRunning: Bool
    @NSManaged public var isActive: Bool
}
