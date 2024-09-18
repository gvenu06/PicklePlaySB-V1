//  FindView.swift
//  PicklePlaySB V1
//
//  Created by ganeshan venu and chungusdith on 8/13/24.
//

import SwiftUI
import MapKit

struct FindView: View {
    @State private var cameraPosition: MapCameraPosition = .automatic // Initialize with automatic or a default
        @State private var courtLocations: [MKMapItem] = [] // Keep this as is
        @StateObject private var locationManager = LocationManager() // Use the LocationManager

    
       var body: some View {
           Map(position: $cameraPosition) {
               // User Location Marker
               Marker("Current Location", systemImage: "person", coordinate: locationManager.region.center)
                   .foregroundStyle(.red.opacity(0.25))
               
               Marker("Veterans Park", systemImage: "figure.pickleball", coordinate: .VeteransParkLoc).tint(.blue)
               Marker("Reichler Park", systemImage: "figure.pickleball", coordinate: .ReichlerParkLoc).tint(.blue)
               Marker("Kingsley Park", systemImage: "figure.pickleball", coordinate: .KinglseyParkLoc).tint(.blue)
               Marker("Thompson Park", systemImage: "figure.pickleball", coordinate: .ThomopsonParkLoc).tint(.blue)
               
               ForEach(courtLocations, id: \.self) { court in
                   if let location = court.placemark.location?.coordinate {
                       Marker(court.name ?? "Pickleball Court", systemImage: "figure.pickleball", coordinate: location).tint(.blue)
                   }
               }
           }
           .mapStyle(.standard(elevation: .realistic))
           .onAppear {
               searchForPickleballCourts()
                cameraPosition = .region(
                   MKCoordinateRegion(center: locationManager.region.center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
               )
           }
           .onReceive(locationManager.$region) { newRegion in
               let userCoordinate = newRegion.center
            let distanceThreshold: CLLocationDistance = 200 // meters
               let currentLocation = locationManager.region.center
               if CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
                   .distance(from: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)) > distanceThreshold {
                   cameraPosition = .region(newRegion)
               }
           }
       }
    //dont touch this method
    func searchForPickleballCourts() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "pickleball court"
        request.region = MKCoordinateRegion(
            center: .userLocation,
            latitudinalMeters: 75000, longitudinalMeters: 75000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Search Error: \(String(describing: error))")
                return
            }
            courtLocations = response.mapItems
        }
    }
   }
    

extension CLLocationCoordinate2D{
    static var userLocation: CLLocationCoordinate2D{
        return .init(latitude: 40.4101, longitude: -74.5691)
    }
    
    static var VeteransParkLoc: CLLocationCoordinate2D{
        return .init(latitude: 40.42470409327868, longitude: -74.54260005604695)
    }
    static var ReichlerParkLoc: CLLocationCoordinate2D{
        return .init(latitude: 40.38473712792281, longitude: -74.53538200227689)
    }
    static var KinglseyParkLoc: CLLocationCoordinate2D{
        return .init(latitude: 40.41758052753993, longitude: -74.57118204645428)
    }
    static var ThomopsonParkLoc: CLLocationCoordinate2D{
        return .init(latitude: 40.337491694250524, longitude: -74.43165428813286)
    }
    
}

extension MKCoordinateRegion{
    
    static var userRegion: MKCoordinateRegion{
        return .init(center: .userLocation, latitudinalMeters: 7500, longitudinalMeters: 7500)
    }
}
#Preview {
    FindView()
}
