// CourtDetailView.swift
struct CourtDetailView: View {
    let courtName: String
    let coordinate: CLLocationCoordinate2D
    @State private var showingQueueView = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(courtName)
                .font(.title)
                .bold()
            
            VStack(alignment: .leading, spacing: 10) {
                Label("Location", systemImage: "mappin.circle.fill")
                Text("Lat: \(coordinate.latitude)")
                Text("Long: \(coordinate.longitude)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button(action: {
                showingQueueView = true
            }) {
                Text("Book Court")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingQueueView) {
            QueueView(courtId: courtName.replacingOccurrences(of: " ", with: "_"))
        }
    }
}
