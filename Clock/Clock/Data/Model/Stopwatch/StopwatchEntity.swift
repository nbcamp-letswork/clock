//
//  StopwatchEntity.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import CoreData

@objc(Stopwatch)
public class StopwatchEntity: NSManagedObject {
    @NSManaged public var isRunning: Bool
    @NSManaged public var laps: Set<LapEntity>?
}
