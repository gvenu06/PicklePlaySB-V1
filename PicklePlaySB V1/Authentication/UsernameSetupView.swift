import SwiftUI

struct UsernameSetupView: View {
    @StateObject private var viewModel = UsernameSetupViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a Username")
                .font(.title)
                .padding(.top)
            
            Text("This will be displayed to other players")
                .foregroundColor(.gray)
            
            TextField("Username", text: $viewModel.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            
            if viewModel.isChecking {
                ProgressView()
            } else if viewModel.isAvailable {
                Text("Username is available!")
                    .foregroundColor(.green)
            } else if !viewModel.availabilityMessage.isEmpty {
                Text(viewModel.availabilityMessage)
                    .foregroundColor(.red)
            }
            
            Button {
                Task {
                    await viewModel.createAccount(email: viewModel.email,
                                                password: viewModel.password,
                                                showSignInView: $showSignInView)
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Create Account")
                        .foregroundColor(.white)
                }
            }
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(viewModel.isAvailable ? Color.blue : Color.gray)
            .cornerRadius(10)
            .disabled(!viewModel.isAvailable || viewModel.isLoading)
            
            Spacer()
        }
        .padding()
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

@MainActor
class UsernameSetupViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isChecking = false
    @Published var isAvailable = false
    @Published var availabilityMessage = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private var checkTask: Task<Void, Never>?
    
    func checkUsername() async {
        guard username.count >= 3 else {
            availabilityMessage = "Username must be at least 3 characters"
            isAvailable = false
            return
        }
        
        isChecking = true
        
        do {
            let snapshot = try await Database.database().reference()
                .child("usernames")
                .child(username.lowercased())
                .getData()
            
            isAvailable = !snapshot.exists()
            availabilityMessage = isAvailable ? "" : "Username is taken"
        } catch {
            availabilityMessage = "Error checking username"
            isAvailable = false
        }
        
        isChecking = false
    }
    
    func createAccount(email: String, password: String, showSignInView: Binding<Bool>) async {
        isLoading = true
        
        do {
            try await AuthenticationManager.shared.createUser(
                email: email,
                password: password,
                username: username
            )
            showSignInView.wrappedValue = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}
