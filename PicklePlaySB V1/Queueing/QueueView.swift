import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct QueueView: View {
    let courtId: String
    @StateObject private var viewModel: QueueViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(courtId: String) {
        self.courtId = courtId
        self._viewModel = StateObject(wrappedValue: QueueViewModel(courtId: courtId))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Date Picker
                DatePickerSection(
                    selectedDate: $viewModel.selectedDate,
                    onDateChange: { viewModel.showingTimeSlots = true }
                )
                
                // Time Slots
                if viewModel.showingTimeSlots {
                    ScrollView {
                        TimeSlotGrid(
                            timeSlots: viewModel.timeSlots,
                            selectedTime: viewModel.selectedTime,
                            isTimeSlotPassed: viewModel.isTimeSlotPassed,
                            onTimeSlotSelected: { time in
                                viewModel.selectTimeSlot(time)
                                Task {
                                    await viewModel.loadQueueForTimeSlot()
                                }
                            }
                        )
                    }
                }
                
                // Queue Section
                if let selectedTime = viewModel.selectedTime {
                    QueueSection(
                        viewModel: viewModel,
                        selectedTime: selectedTime,
                        onJoinQueue: { Task { await viewModel.joinQueue() } },
                        onLeaveQueue: { Task { await viewModel.leaveQueue() } }
                    )
                }
            }
            .navigationTitle("Book Court")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert("Queue Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onDisappear {
                viewModel.cleanup()
            }
        }
    }
}

// Helper Views
private struct DatePickerSection: View {
    @Binding var selectedDate: Date
    let onDateChange: () -> Void
    
    var body: some View {
        DatePicker(
            "Select Date",
            selection: $selectedDate,
            in: Date()...,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .padding()
        .onChange(of: selectedDate) { _ in
            onDateChange()
        }
    }
}

private struct QueueSection: View {
    @ObservedObject var viewModel: QueueViewModel
    let selectedTime: Date
    let onJoinQueue: () -> Void
    let onLeaveQueue: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Current Queue")
                .font(.headline)
            
            if viewModel.isLoadingQueue {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            } else if viewModel.queueEntries.isEmpty {
                Text("No players in queue")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                QueueEntriesList(
                    entries: viewModel.queueEntries,
                    currentUserId: viewModel.currentUserId
                )
            }
            
            // Action Buttons
            if !viewModel.isLoading {
                QueueActionButton(
                    isUserInQueue: viewModel.isUserInQueue,
                    isLoading: viewModel.isLoading,
                    onJoin: onJoinQueue,
                    onLeave: onLeaveQueue
                )
            }
        }
        .padding()
    }
}

private struct QueueEntriesList: View {
    let entries: [QueueManager.QueueEntry]
    let currentUserId: String?
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(entries) { entry in
                QueueEntryView(
                    entry: entry,
                    isCurrentUser: entry.userId == currentUserId
                )
                
                if entry.position < entries.count - 1 {
                    Divider()
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

private struct QueueActionButton: View {
    let isUserInQueue: Bool
    let isLoading: Bool
    let onJoin: () -> Void
    let onLeave: () -> Void
    
    var body: some View {
        Group {
            if !isUserInQueue {
                Button(action: onJoin) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("Join Queue")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else {
                Button(action: onLeave) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Leave Queue")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
        .disabled(isLoading)
        .padding(.horizontal)
    }
}

// Preview Provider
struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView(courtId: "court_1")
    }
}
