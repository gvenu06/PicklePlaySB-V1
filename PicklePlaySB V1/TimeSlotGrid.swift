//
//  TimeSlotGrid.swift
//  PicklePlaySB V1
//
//  Created by Foyez Siddiqui on 10/27/24.
//


import SwiftUI

struct TimeSlotGrid: View {
    let timeSlots: [Date]
    let selectedTime: Date?
    let isTimeSlotPassed: (Date) -> Bool
    let onTimeSlotSelected: (Date) -> Void
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            ForEach(timeSlots, id: \.self) { time in
                TimeSlotButton(
                    time: time,
                    isSelected: selectedTime == time,
                    action: { onTimeSlotSelected(time) }
                )
                .disabled(isTimeSlotPassed(time))
                .opacity(isTimeSlotPassed(time) ? 0.5 : 1.0)
            }
        }
        .padding()
    }
}

struct QueueEntryView: View {
    let entry: QueueManager.QueueEntry
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            Text("\(entry.position + 1).")
                .foregroundColor(.gray)
                .frame(width: 30)
            Text(entry.username)
                .fontWeight(isCurrentUser ? .bold : .regular)
            Spacer()
            if isCurrentUser {
                Text("You")
                    .font(.footnote)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}