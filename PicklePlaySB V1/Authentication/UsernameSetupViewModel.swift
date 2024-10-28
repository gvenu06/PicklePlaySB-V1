import SwiftUI
import FirebaseDatabase

@MainActor
class UsernameSetupViewModel: ObservableObject {
    @Published var username = ""
    @Published var isChecking = false
    @Published var isAvailable = false
    @Published var availabilityMessage = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let database = Database.database().reference()
    
    func validateUsername() -> Bool {
        // Username must be at least 3 characters
        guard username.count >= 3 else {
            availabilityMessage = "Username must be at least 3 characters"
            isAvailable = false
            return false
        }
        
        // Only allow alphanumeric characters and underscores
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        guard username.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
            availabilityMessage = "Username can only contain letters, numbers, and underscores"
            isAvailable = false
            return false
        }
        
        return true
    }
    
    func checkUsername() async {
        guard validateUsername() else { return }
        
        isChecking = true
        availabilityMessage = ""
        
        do {
            print("DEBUG: Checking username:", username) // Debug print
            
            let snapshot = try await database
                .child("usernames")
                .child(username.lowercased())
                .getData()
            
            print("DEBUG: Username check result - exists:", snapshot.exists()) // Debug print
            
            await MainActor.run {
                isAvailable = !snapshot.exists()
                availabilityMessage = isAvailable ? "Username is available!" : "Username is already taken"
                isChecking = false
            }
        } catch {
            print("DEBUG: Username check error:", error.localizedDescription) // Debug print
            
            await MainActor.run {
                availabilityMessage = "Error checking username availability"
                isAvailable = false
                isChecking = false
            }
        }
    }
    
    func createAccount(email: String, password: String, showSignInView: Binding<Bool>) async {
        guard validateUsername() else {
            errorMessage = availabilityMessage
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            print("DEBUG: Starting account creation for username:", username)
            try await AuthenticationManager.shared.createUser(
                email: email,
                password: password,
                username: username
            )
            showSignInView.wrappedValue = false
        } catch {
            print("DEBUG: Account creation error:", error)
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}