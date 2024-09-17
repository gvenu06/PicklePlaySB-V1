//  FindView.swift
//  PicklePlaySB V1
//
//  Created by ganeshan venu on 8/13/24.
//

import SwiftUI
import MapKit

struct FindView: View {
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var cameraPosition:  MapCameraPosition = .region(.userRegion)
    @State private var courtLocations: [MKMapItem] = [] //dont touch
    
    
    
    var body: some View {
        Map(position: $position){
            
            Marker("My Loc",systemImage: "person" ,coordinate: .userLocation).foregroundStyle(.red.opacity(0.25))
            
          
            Marker("Veterans Park",systemImage: "figure.pickleball" ,coordinate:  .VeteransParkLoc).tint(.blue) //dont touch
            
            Marker("Reichler Park",systemImage: "figure.pickleball" ,coordinate: .ReichlerParkLoc).tint(.blue) //dont touch
            
            Marker("Kingsley Park",systemImage: "figure.pickleball" ,coordinate: .KinglseyParkLoc).tint(.blue) //dont touch
            
            Marker("Thompson Park",systemImage: "figure.pickleball" ,coordinate: .ThomopsonParkLoc).tint(.blue) //dont touch
            //dont touch
            ForEach(courtLocations, id: \.self) { court in
                if let location=court.placemark.location?.coordinate {
                    Marker(court.name ?? "Pickleball Court", systemImage: "figure.pickleball", coordinate: location).tint(.blue)
                }
                
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .onAppear{
            CLLocationManager().requestWhenInUseAuthorization()
            searchForPickleballCourts()//dont touch
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
        return .init(center: .userLocation, latitudinalMeters: 5000, longitudinalMeters: 5000)
    }
}
#Preview {
    FindView()
}
