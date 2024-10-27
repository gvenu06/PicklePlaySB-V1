import SwiftUI
import FirebaseAuth
import FirebaseDatabase

class ProfileView: ObservableObject {
    @Published var user: AuthDataResultModel?
    @Published var bookings: [QueueManager.BookingModel] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    func loadUserData() {
        isLoading = true
        
        do {
            user = try AuthenticationManager.shared.getAuthenticatedUser()
            if let userId = user?.uid {
                QueueManager.shared.getUserBookings(forUserId: userId) { [weak self] (bookings: [QueueManager.BookingModel]) in
                    DispatchQueue.main.async {
                        self?.bookings = bookings.sorted { $0.gameTime > $1.gameTime }
                        self?.isLoading = false
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
    
    func cancelBooking(_ booking: QueueManager.BookingModel) {
        QueueManager.shared.cancelBooking(
            bookingId: booking.id,
            userId: booking.userId,
            courtId: booking.courtId
        ) { [weak self] (success: Bool, error: Error?) in
            DispatchQueue.main.async {
                if success {
                    self?.loadUserData()
                } else {
                    self?.errorMessage = error?.localizedDescription ?? "Failed to cancel booking"
                    self?.showError = true
                }
            }
        }
    }
}
