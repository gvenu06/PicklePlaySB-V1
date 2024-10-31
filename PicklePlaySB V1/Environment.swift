// Create new file called Environment.swift
enum Environment {
    case development
    case production
    
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    var databaseURL: String {
        switch self {
        case .development:
            return FirebaseConfig.databaseURL + "-dev"
        case .production:
            return FirebaseConfig.databaseURL
        }
    }
    
    var isDebug: Bool {
        switch self {
        case .development:
            return true
        case .production:
            return false
        }
    }
}