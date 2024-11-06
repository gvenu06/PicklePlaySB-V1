import FirebaseDatabase
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    private let database = Database.database()
    
    private init() {}
    
    func validateConnection() async -> Bool {
        return await withCheckedContinuation { continuation in
            let connectedRef = database.reference(withPath: ".info/connected")
            connectedRef.observe(.value) { snapshot in
                continuation.resume(returning: snapshot.value as? Bool ?? false)
            }
        }
    }
    
    func checkDatabaseAccess() async -> Bool {
        do {
            let testRef = database.reference().child("system_checks/connection_test")
            try await testRef.setValue(ServerValue.timestamp())
            try await testRef.removeValue()
            return true
        } catch {
            print("Database access check failed:", error.localizedDescription)
            return false
        }
    }
    
    #if DEBUG
    func printDatabaseInfo() {
        print("📊 Firebase Database Configuration:")
        print("URL:", database.reference().url)
        print("Persistence Enabled:", database.isPersistenceEnabled)
        if let currentUser = Auth.auth().currentUser {
            print("Current User:", currentUser.uid)
            print("User Email:", currentUser.email ?? "No email")
        } else {
            print("No user authenticated")
        }
    }
    #endif
}