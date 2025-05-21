//
//  CoreDataError.swift
//  Clock
//
//  Created by youseokhwan on 5/21/25.
//

import Foundation

enum CoreDataError: Error {
    case deallocated
    case fetchFailed(String)
    case insertFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
}
