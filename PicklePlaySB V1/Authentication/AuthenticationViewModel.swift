import SwiftUI
import FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    @Published var showSignInView: Bool = false
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        do {
            _ = try AuthenticationManager.shared.getAuthenticatedUser()
            showSignInView = false
        } catch {
            showSignInView = true
        }
    }
    
    func signOut() {
        do {
            try AuthenticationManager.shared.signOut()
            showSignInView = true
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    func setSignedIn() {
        showSignInView = false
    }
}
