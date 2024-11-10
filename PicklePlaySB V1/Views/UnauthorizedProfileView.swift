import SwiftUI

struct UnauthorizedProfileView: View {
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    let onSignInComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Sign in to view your profile")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            Text("Access your bookings and manage your account")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button {
                // Present sign in view
                authViewModel.showSignInView = true
                onSignInComplete()
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Profile")
    }
}