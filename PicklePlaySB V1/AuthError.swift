import Foundation

enum AuthError: LocalizedError {
    case usernameTaken
    case userNotFound
    case userDataNotFound
    case invalidUsername
    case networkError
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .usernameTaken:
            return "This username is already taken"
        case .userNotFound:
            return "User not found"
        case .userDataNotFound:
            return "User data not found"
        case .invalidUsername:
            return "Username must be at least 3 characters and contain only letters, numbers, and underscores"
        case .networkError:
            return "Network error occurred. Please try again"
        case .databaseError(let message):
            return "Database error: \(message)"
        }
    }
}