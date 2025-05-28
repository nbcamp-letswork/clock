import Foundation

struct TimerNotification: Codable {
    let id: UUID
    let title: String
    let body: String
    let sound: String
    let categoryIdentifier: String
    let date: Date
}
