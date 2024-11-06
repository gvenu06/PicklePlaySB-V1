import Foundation
import FirebaseCore
import CryptoKit

class CertificatePinningManager: NSObject, URLSessionDelegate {
    static let shared = CertificatePinningManager()
    
    // Firebase's public key hashes - you can get these by running:
    // openssl s_client -connect YOUR_FIREBASE_URL:443 < /dev/null 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
    private let trustedKeys = [
        "kwG0TbKKegMm7Q9puQHxme0NVwNgBPmOAR2vqMmy/4E="
    ]
    
    func urlSession(_ session: URLSession,
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Only pin firebase.google.com and firebaseio.com domains
        guard let serverHost = challenge.protectionSpace.host,
              serverHost.contains("firebase") else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust,
           let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            
            let serverCertData = SecCertificateCopyData(certificate) as Data
            let serverHash = Data(SHA256.hash(data: serverCertData)).base64EncodedString()
            
            if trustedKeys.contains(serverHash) {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    // Create pinned session configuration
    func createPinnedSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        return configuration
    }
}
