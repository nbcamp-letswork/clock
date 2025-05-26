//
//  LapEntity.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import CoreData

@objc(Lap)
public class LapEntity: NSManagedObject {
    @NSManaged public var lapNumber: Int16
    @NSManaged public var time: Double
    @NSManaged public var stopwatch: StopwatchEntity?
}
