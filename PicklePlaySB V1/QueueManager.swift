import Firebase
import FirebaseFirestore

class QueueManager {
    static let shared = QueueManager()
    private let db = Firestore.firestore()
    private var listeners: [String: ListenerRegistration] = [:]
    
    private init() {}
    
    func addUserToQueue(userId: String, courtId: String, gameTime: Date, completion: @escaping (Bool, Error?) -> Void) {
        let queueRef = db.collection("queues").document(courtId)
        
        let userData: [String: Any] = [
            "userId": userId,
            "gameTime": gameTime,
            "registrationTime": FieldValue.serverTimestamp()
        ]
        
        queueRef.updateData([
            "players": FieldValue.arrayUnion([userData])
        ]) { error in
            if let error = error {
                print("Error adding user to queue: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("User successfully added to queue")
                completion(true, nil)
            }
        }
    }
    
    func removeUserFromQueue(userId: String, courtId: String, completion: @escaping (Bool, Error?) -> Void) {
        let queueRef = db.collection("queues").document(courtId)
        
        queueRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if var players = document.data()?["players"] as? [[String: Any]] {
                    players.removeAll { $0["userId"] as? String == userId }
                    
                    queueRef.updateData(["players": players]) { error in
                        if let error = error {
                            print("Error removing user from queue: \(error.localizedDescription)")
                            completion(false, error)
                        } else {
                            print("User successfully removed from queue")
                            completion(true, nil)
                        }
                    }
                } else {
                    completion(false, NSError(domain: "QueueManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Players data not found"]))
                }
            } else {
                completion(false, error ?? NSError(domain: "QueueManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]))
            }
        }
    }
    
    func observeQueue(courtId: String, completion: @escaping ([[String: Any]]?) -> Void) {
        let queueRef = db.collection("queues").document(courtId)
        
        let listener = queueRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                completion(nil)
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                completion(nil)
                return
            }
            let players = data["players"] as? [[String: Any]] ?? []
            completion(players)
        }
        
        listeners[courtId] = listener
    }
    
    func stopObservingQueue(courtId: String) {
        listeners[courtId]?.remove()
        listeners.removeValue(forKey: courtId)
    }
}
