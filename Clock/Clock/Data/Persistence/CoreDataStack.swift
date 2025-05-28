//
//  CoreDataStack.swift
//  Clock
//
//  Created by youseokhwan on 5/28/25.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")

        // AppGroup 설정
        let appGroupID = "group.nbcamp-letswork.ClockApp"
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { fatalError() }

        // 저장소 경로 설정
        let storeURL = groupURL.appendingPathComponent("AlarmModel.sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]

        // CoreData Load
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData Error: \(error)")
            }
        }
        return container
    }()

    private init() {}
}
