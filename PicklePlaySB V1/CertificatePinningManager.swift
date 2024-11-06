import Foundation
import CryptoKit

class CertificatePinningManager: NSObject, URLSessionDelegate {
    static let shared = CertificatePinningManager()
    
    // Store your certificates' public key hashes here
    private let trustedPublicKeyHashes = [
        "hash1", // Replace with your actual certificate hash
        "hash2"  // Add backup certificate hash if needed
    ]
    
    func urlSession(_ session: URLSession,
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // Extract public key from certificate
        let serverPublicKey = SecCertificateCopyKey(certificate)
        let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil)!
        let serverHashData = Data(SHA256.hash(data: serverPublicKeyData as Data))
        let serverHash = serverHashData.base64EncodedString()
        
        if trustedPublicKeyHashes.contains(serverHash) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    // Create a URLSession with certificate pinning
    func createPinnedSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
}