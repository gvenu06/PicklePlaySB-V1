import FirebaseDatabase
import FirebaseAuth

class QueueManager {
    static let shared = QueueManager()
    private let ref: DatabaseReference
    private var listeners: [String: DatabaseHandle] = [:]
    
    private init() {
        ref = Database.database().reference()
    }
    
    func getUserBookings(forUserId userId: String, completion: @escaping ([BookingModel]) -> Void) {
        let userBookingsRef = ref.child("users").child(userId).child("bookings")
        
        userBookingsRef.observeSingleEvent(of: .value) { snapshot in
            var bookings: [BookingModel] = []
            
            for child in snapshot.children {
                guard let snapshot = child as? DataSnapshot,
                      let data = snapshot.value as? [String: Any],
                      let userId = data["userId"] as? String,
                      let courtId = data["courtId"] as? String,
                      let timeInterval = data["gameTime"] as? TimeInterval,
                      let status = data["status"] as? String
                else { continue }
                
                let booking = BookingModel(
                    id: snapshot.key,
                    userId: userId,
                    courtId: courtId,
                    gameTime: Date(timeIntervalSince1970: timeInterval),
                    status: status
                )
                
                bookings.append(booking)
            }
            
            completion(bookings)
        }
    }
    
    func cancelBooking(bookingId: String, userId: String, courtId: String, completion: @escaping (Bool, Error?) -> Void) {
        let updates: [String: Any?] = [
            "/queues/\(courtId)/bookings/\(bookingId)": nil,
            "/users/\(userId)/bookings/\(bookingId)": nil
        ]
        
        ref.updateChildValues(updates as [String: Any]) { error, _ in
            completion(error == nil, error)
        }
    }
    
    func joinQueue(courtId: String, gameTime: Date) async throws -> QueueEntry {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        // Get user data
        let userSnapshot = try await ref.child("users").child(currentUser.uid).getData()
        guard let userData = userSnapshot.value as? [String: Any],
              let username = userData["username"] as? String else {
            throw AuthError.userDataNotFound
        }
        
        // Get current queue for the time slot
        let timeSlotKey = dateToTimeSlotKey(gameTime)
        let queueRef = ref.child("queues").child(courtId).child("timeSlots").child(timeSlotKey)
        
        let queueSnapshot = try await queueRef.getData()
        let position = queueSnapshot.children.allObjects.count
        
        let entryId = queueRef.childByAutoId().key ?? UUID().uuidString
        
        let queueData: [String: Any] = [
            "userId": currentUser.uid,
            "username": username,
            "courtId": courtId,
            "gameTime": gameTime.timeIntervalSince1970,
            "position": position,
            "status": QueueStatus.waiting.rawValue,
            "joinedAt": ServerValue.timestamp()
        ]
        
        // Add to queue and user's bookings
        let updates: [String: Any] = [
            "queues/\(courtId)/timeSlots/\(timeSlotKey)/\(entryId)": queueData,
            "users/\(currentUser.uid)/bookings/\(entryId)": queueData
        ]
        
        try await ref.updateChildValues(updates)
        
        return QueueEntry(
            id: entryId,
            userId: currentUser.uid,
            username: username,
            courtId: courtId,
            gameTime: gameTime,
            position: position,
            status: QueueStatus.waiting.rawValue
        )
    }
    
    func leaveQueue(entryId: String, courtId: String, gameTime: Date) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        let timeSlotKey = dateToTimeSlotKey(gameTime)
        let updates: [String: Any?] = [
            "queues/\(courtId)/timeSlots/\(timeSlotKey)/\(entryId)": nil,
            "users/\(currentUser.uid)/bookings/\(entryId)": nil
        ]
        
        try await ref.updateChildValues(updates as [String: Any])
    }
    
    func observeQueue(courtId: String, gameTime: Date, completion: @escaping ([QueueEntry]) -> Void) -> DatabaseHandle {
        let timeSlotKey = dateToTimeSlotKey(gameTime)
        let queueRef = ref.child("queues").child(courtId).child("timeSlots").child(timeSlotKey)
        
        let handle = queueRef.observe(.value) { snapshot in
            var entries: [QueueEntry] = []
            
            for child in snapshot.children {
                guard let snapshot = child as? DataSnapshot,
                      let data = snapshot.value as? [String: Any],
                      let userId = data["userId"] as? String,
                      let username = data["username"] as? String,
                      let timeInterval = data["gameTime"] as? TimeInterval,
                      let position = data["position"] as? Int,
                      let statusRaw = data["status"] as? String,
                      let status = QueueStatus(rawValue: statusRaw)
                else { continue }
                
                let entry = QueueEntry(
                    id: snapshot.key,
                    userId: userId,
                    username: username,
                    courtId: courtId,
                    gameTime: Date(timeIntervalSince1970: timeInterval),
                    position: position,
                    status: QueueStatus.waiting.rawValue
                )
                
                entries.append(entry)
            }
            
            completion(entries.sorted { $0.position < $1.position })
        }
        
        listeners["\(courtId)_\(timeSlotKey)"] = handle
        return handle
    }
    
    func stopObservingQueue(courtId: String, gameTime: Date) {
        let timeSlotKey = dateToTimeSlotKey(gameTime)
        let key = "\(courtId)_\(timeSlotKey)"
        
        if let handle = listeners[key] {
            ref.child("queues").child(courtId).child("timeSlots").child(timeSlotKey)
                .removeObserver(withHandle: handle)
            listeners.removeValue(forKey: key)
        }
    }
    
    private func dateToTimeSlotKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        return formatter.string(from: date)
    }
}
