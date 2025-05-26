//
//  StopwatchRepository.swift
//  Clock
//
//  Created by youseokhwan on 5/26/25.
//

import Foundation

protocol StopwatchRepository {
    func fetch() async -> Result<Stopwatch, Error>
    func save(_ stopwatch: Stopwatch) async -> Result<Void, Error>
    func delete() async -> Result<Void, Error>
}
