import SwiftUI
import FirebaseAuth

@MainActor
class QueueViewModel: ObservableObject {
    private let courtId: String
    @Published var selectedDate = Date()
    @Published var selectedTime: Date?
    @Published var showingTimeSlots = false
    @Published var isLoading = false
    @Published var isLoadingQueue = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var queueEntries: [QueueManager.QueueEntry] = []
    
    init(courtId: String) {
        self.courtId = courtId
    }
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    var isUserInQueue: Bool {
        guard let currentUserId = currentUserId else { return false }
        return queueEntries.contains { $0.userId == currentUserId }
    }
    
    private var queueObserver: DatabaseHandle?
    
    let timeSlots: [Date] = {
        let calendar = Calendar.current
        let startTime = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: Date())!
        let endTime = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
        var slots: [Date] = []
        var currentSlot = startTime
        
        while currentSlot <= endTime {
            slots.append(currentSlot)
            currentSlot = calendar.date(byAdding: .minute, value: 30, to: currentSlot)!
        }
        return slots
    }()
    
    func selectTimeSlot(_ time: Date) {
        selectedTime = time
    }
    
    func isTimeSlotPassed(_ time: Date) -> Bool {
        if Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
            return time < Date()
        }
        return false
    }
    
    func loadQueueForTimeSlot() async {
        guard let time = selectedTime else { return }
        
        isLoadingQueue = true
        queueObserver = QueueManager.shared.observeQueue(courtId: courtId, gameTime: time) { [weak self] entries in
            DispatchQueue.main.async {
                self?.queueEntries = entries
                self?.isLoadingQueue = false
            }
        }
    }
    
    func joinQueue() async {
        guard let time = selectedTime else { return }
        
        isLoading = true
        do {
            _ = try await QueueManager.shared.joinQueue(courtId: courtId, gameTime: time)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    func leaveQueue() async {
        guard let time = selectedTime,
              let entry = queueEntries.first(where: { $0.userId == currentUserId }) else { return }
        
        isLoading = true
        do {
            try await QueueManager.shared.leaveQueue(entryId: entry.id, courtId: courtId, gameTime: time)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    func cleanup() {
        if let time = selectedTime {
            QueueManager.shared.stopObservingQueue(courtId: courtId, gameTime: time)
        }
    }
}