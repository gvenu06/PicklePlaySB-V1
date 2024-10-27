import SwiftUI
import MapKit

struct CourtDetailView: View {
    let courtName: String
    let coordinate: CLLocationCoordinate2D
    @State private var showingQueueView = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Main container with darkened background
        ZStack {
            // Semi-transparent black background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Content card
            VStack(spacing: 20) {
                // Drag indicator
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)
                
                // Court name
                Text(courtName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Location info
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text("Location Details")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                    }
                    
                    Text("This court is located at:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(String(format: "%.6f°N", coordinate.latitude))
                            Text(String(format: "%.6f°W", coordinate.longitude))
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Schedule button
                Button {
                    showingQueueView = true
                } label: {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("Schedule Court?")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Cancel button
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom)
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .frame(height: UIScreen.main.bounds.height * 0.45)
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingQueueView) {
            QueueView(courtId: courtName.replacingOccurrences(of: " ", with: "_"))
        }
    }
}

struct CourtDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CourtDetailView(
            courtName: "Sample Court",
            coordinate: CLLocationCoordinate2D(latitude: 40.4101, longitude: -74.5691)
        )
    }
}
