import CryptoKit
import Foundation

class SecurityManager {
    static let shared = SecurityManager()
    
    // Encrypt sensitive data before storing
    func encryptSensitiveData(_ data: String) -> String? {
        guard let dataData = data.data(using: .utf8) else { return nil }
        
        do {
            let key = SymmetricKey(size: .bits256)
            let sealedBox = try AES.GCM.seal(dataData, using: key)
            return sealedBox.combined?.base64EncodedString()
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    // Validate and sanitize input
    func sanitizeInput(_ input: String) -> String? {
        // Remove any potentially harmful characters
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_- "))
        let sanitized = input.components(separatedBy: allowedCharacters.inverted).joined()
        
        if sanitized.isEmpty || sanitized != input {
            return nil
        }
        return sanitized
    }
}