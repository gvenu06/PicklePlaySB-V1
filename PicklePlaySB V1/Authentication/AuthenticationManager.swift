//
//  AuthenticationManager.swift
//  PicklePlaySB V1
//
//  Created by Foyez Siddiqui on 9/26/24.
//
import Foundation
import SwiftUI
import FirebaseAuth

struct AuthDataResultModel
{
    let uid: String
    let email: String?
    let photoURL: String?
    
    init(user:User){
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
        
    }
}

final class AuthenticationManager{
    static let shared = AuthenticationManager()
    private init(){}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        return(AuthDataResultModel(user:user))
    }

    func createUser(email: String, password: String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
