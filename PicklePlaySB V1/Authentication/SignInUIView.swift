//
//  SignInUIView.swift
//  PicklePlaySB V1
//
//  Created by Foyez Siddiqui on 9/26/24.
//

import SwiftUI
@MainActor
final class SignInUIViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    func signIn(){
        guard !email.isEmpty, !password.isEmpty else{
            print("No email or password found")
            return
        }
        Task{
            do{
                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                print("success")
                print(returnedUserData)
            }
            catch{
                print("Error: \(error)")
            }
        }
    }
}
struct SignInUIView: View {
    @StateObject private var viewModel = SignInUIViewModel()
    
    var body: some View {
        VStack{
            TextField("Email...", text:$viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            SecureField("Password...", text:$viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button{
                viewModel.signIn()
            }label:{
                Text("Sign in")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height:55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign in with Email")
    }
}

struct SignInUiView_Preview: PreviewProvider{
    static var previews: some View{
        NavigationStack{
            SignInUIView()
        }
    }
}
