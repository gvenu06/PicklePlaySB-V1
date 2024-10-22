// QueueView.swift
struct QueueView: View {
    let courtId: String
    @State private var selectedDate = Date()
    @State private var selectedTime: Date?
    @State private var showingTimeSlots = false
    @State private var isBooking = false
    @State private var showingConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    private let timeSlots: [Date] = {
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
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .onChange(of: selectedDate) { newDate in
                    showingTimeSlots = true
                }
                
                if showingTimeSlots {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(timeSlots, id: \.self) { time in
                                TimeSlotButton(
                                    time: time,
                                    isSelected: selectedTime == time,
                                    action: {
                                        selectedTime = time
                                        bookCourt()
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Book Court")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert("Booking Confirmation", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your court has been booked for \(formatDate(selectedTime ?? Date()))")
            }
        }
    }
    
    private func bookCourt() {
        guard let time = selectedTime else { return }
        isBooking = true
        
        // Get the current user's ID from AuthenticationManager
        do {
            let user = try AuthenticationManager.shared.getAuthenticatedUser()
            QueueManager.shared.addUserToQueue(userId: user.uid, courtId: courtId, gameTime: time) { success, error in
                isBooking = false
                if success {
                    showingConfirmation = true
                }
            }
        } catch {
            print("Error getting authenticated user: \(error)")
            isBooking = false
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
