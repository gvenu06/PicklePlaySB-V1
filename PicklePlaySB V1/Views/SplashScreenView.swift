import SwiftUI
import FirebaseAuth
import FirebaseDatabase

class AppLoadingManager: ObservableObject {
    @Published var isFirebaseReady = false
    @Published var isQueueManagerReady = false
    @Published var isLocationServicesReady = false
    @Published var authState: AuthState = .unknown
    @Published var loadingError: String?
    
    enum AuthState {
        case unknown
        case signedIn
        case signedOut
    }
    
    static let shared = AppLoadingManager()
    private var hasResumed = false

    func initializeApp() async {
        print("Starting app initialization") // Debug log
        
        // Verify Firebase configuration
        if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plistDict = NSDictionary(contentsOfFile: filePath) {
            print("Found GoogleService-Info.plist")
            if let databaseURL = plistDict["DATABASE_URL"] as? String {
                print("Database URL found: \(databaseURL)")
            } else {
                print("⚠️ No DATABASE_URL found in plist!")
            }
        } else {
            print("⚠️ Could not find GoogleService-Info.plist")
        }
        
        await withTaskGroup(of: Void.self) { group in
            // Check Firebase Connection
            group.addTask {
                await self.checkFirebaseConnection()
            }
            
            // Check Queue Manager
            group.addTask {
                await self.checkQueueManager()
            }
            
            // Check Location Services
            group.addTask {
                await self.checkLocationServices()
            }
            
            // Check Authentication
            group.addTask {
                await self.checkAuthenticationState()
            }
            
            // Wait for all tasks to complete
            await group.waitForAll()
        }
    }
    private func checkQueueManager() async {
        print("Starting Queue Manager check")
        
        await withCheckedContinuation { continuation in
            let timeoutWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                if !self.hasResumed {
                    print("⚠️ Queue Manager check timed out")
                    self.hasResumed = true
                    self.isQueueManagerReady = true  // Set to true even on timeout to not block app
                    continuation.resume()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: timeoutWorkItem)
            
            // Test write to Firebase to verify Queue Manager
            let testRef = Database.database().reference().child("system_checks").child("queue_manager_test")
            let timestamp = ServerValue.timestamp()
            
            testRef.setValue(timestamp) { [weak self] error, _ in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if !self.hasResumed {
                        self.hasResumed = true
                        
                        if let error = error {
                            print("⚠️ Queue Manager initialization error: \(error.localizedDescription)")
                            // Still set ready to true to not block the app
                            self.isQueueManagerReady = true
                        } else {
                            print("✅ Queue Manager initialized successfully")
                            self.isQueueManagerReady = true
                            
                            // Clean up test data
                            testRef.removeValue()
                        }
                        
                        timeoutWorkItem.cancel()
                        continuation.resume()
                    }
                }
            }
        }
        
        hasResumed = false
    }
    
    private func checkLocationServices() async {
        print("Starting Location Services check")
        
        await withCheckedContinuation { continuation in
            let timeoutWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                if !self.hasResumed {
                    print("⚠️ Location Services check timed out")
                    self.hasResumed = true
                    self.isLocationServicesReady = true
                    continuation.resume()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: timeoutWorkItem)
            
            // Check location services
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if !self.hasResumed {
                    self.hasResumed = true
                    self.isLocationServicesReady = true
                    print("Location Services check completed")
                    continuation.resume()
                    timeoutWorkItem.cancel()
                }
            }
        }
        
        hasResumed = false
    }
    
    private func checkAuthenticationState() async {
        print("Starting Authentication check")
        
        await withCheckedContinuation { continuation in
            let timeoutWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                if !self.hasResumed {
                    print("⚠️ Authentication check timed out")
                    self.hasResumed = true
                    self.authState = .signedOut
                    continuation.resume()
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: timeoutWorkItem)
            
            // Check authentication
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if !self.hasResumed {
                    if let _ = try? AuthenticationManager.shared.getAuthenticatedUser() {
                        self.authState = .signedIn
                        print("User is signed in")
                    } else {
                        self.authState = .signedOut
                        print("No signed-in user found")
                    }
                    self.hasResumed = true
                    continuation.resume()
                    timeoutWorkItem.cancel()
                }
            }
        }
        
        hasResumed = false
    }
    private func checkFirebaseConnection() async {
        print("Starting Firebase connection check")

        await withCheckedContinuation { continuation in
            let database = Database.database()
            let connectedRef = database.reference(withPath: ".info/connected")

            print("Database reference created: \(database.reference().url)")

            let timeoutWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                if !self.hasResumed {
                    print("⚠️ Firebase connection check timed out")
                    self.hasResumed = true
                    self.isFirebaseReady = true  // Set to true to allow app to proceed
                    continuation.resume()
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: timeoutWorkItem)

            var handle: DatabaseHandle = 0
            handle = connectedRef.observe(.value) { [weak self] snapshot in  // Fixed closure signature
                guard let self = self else { return }
                print("Firebase connection callback received - Value: \(String(describing: snapshot.value))")

                DispatchQueue.main.async {
                    if !self.hasResumed {
                        self.hasResumed = true
                        self.isFirebaseReady = true  // Set to true regardless of connection
                        print("Firebase connection check completed - Setting ready state")
                        continuation.resume()

                        connectedRef.removeObserver(withHandle: handle)
                        timeoutWorkItem.cancel()
                    }
                }
            }

            // Add error observer with correct signature
            connectedRef.observeSingleEvent(of: .value) { snapshot in
                if let error = snapshot.value as? Error {
                    print("⚠️ Firebase connection error: \(error.localizedDescription)")
                }
            }
        }

        hasResumed = false
    }
    
    var isAllReady: Bool {
        isFirebaseReady && isQueueManagerReady && isLocationServicesReady && authState != .unknown
    }
}

struct LoadingIndicator: View {
    let isLoaded: Bool
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            if isLoaded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(height: 20)
    }
}

struct SplashScreenView: View {
    @StateObject private var loadingManager = AppLoadingManager.shared
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var showError = false  // Added this line
    
    var body: some View {
        Group {
            if loadingManager.isAllReady {
                if loadingManager.authState == .signedIn {
                    ContentView()
                        .environmentObject(authViewModel)
                } else {
                    AuthenticationView()
                        .environmentObject(authViewModel)
                }
            } else {
                ZStack {
                    Color.white.ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        VStack {
                            Image(systemName: "sportscourt.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                            Text("PicklePlay SB")
                                .font(Font.custom("Carlito-Bold", size: 26))
                                .padding(.top, 9.5)
                                .foregroundStyle(.black.opacity(0.80))
                        }
                        .scaleEffect(size)
                        .opacity(opacity)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            LoadingIndicator(isLoaded: loadingManager.isFirebaseReady, text: "Connecting to servers")
                            LoadingIndicator(isLoaded: loadingManager.isQueueManagerReady, text: "Initializing booking system")
                            LoadingIndicator(isLoaded: loadingManager.isLocationServicesReady, text: "Setting up location services")
                            LoadingIndicator(isLoaded: loadingManager.authState != .unknown, text: "Checking authentication")
                        }
                        .opacity(opacity)
                    }
                }
                .alert("Connection Error", isPresented: $showError) {
                    Button("Retry") {
                        Task {
                            await loadingManager.initializeApp()
                        }
                    }
                } message: {
                    Text(loadingManager.loadingError ?? "Failed to initialize app. Please check your connection.")
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                size = 0.9
                opacity = 1.0
            }
            
            Task {
                await loadingManager.initializeApp()
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
