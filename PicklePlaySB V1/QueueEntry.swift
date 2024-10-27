import Foundation

extension QueueManager {
    struct QueueEntry: Identifiable {
        let id: String
        let userId: String
        let username: String
        let courtId: String
        let gameTime: Date
        let position: Int
        let status: String
    }
    
    struct BookingModel: Identifiable {
        let id: String
        let userId: String
        let courtId: String
        let gameTime: Date
        let status: String
    }
}