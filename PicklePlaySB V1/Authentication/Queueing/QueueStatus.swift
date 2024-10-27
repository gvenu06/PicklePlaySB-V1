//
//  QueueStatus.swift
//  PicklePlaySB V1
//
//  Created by Foyez Siddiqui on 10/27/24.
//


import Foundation

enum QueueStatus: String {
    case waiting = "waiting"
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
}

struct QueueEntry: Identifiable {
    let id: String
    let userId: String
    let username: String
    let courtId: String
    let gameTime: Date
    let position: Int
    let status: QueueStatus  // Make sure this is QueueStatus, not String
}

struct BookingModel: Identifiable {
    let id: String
    let userId: String
    let courtId: String
    let gameTime: Date
    let status: String
}
