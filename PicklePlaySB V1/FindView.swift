//
//  FindView.swift
//  PicklePlaySB V1
//
//  Created by ganeshan venu on 8/13/24.
//

import SwiftUI
import MapKit

struct FindView: View {
    @State private var cameraPosition:  MapCameraPosition = .region(.userRegion)
    
    
    
    var body: some View {
        Map(position: $cameraPosition){
            //Marker("My Location", coordinate: .userLocation)
            /*Annotation("My Location", coordinate: .userLocation){
                ZStack{
                    Circle()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.blue.opacity(0.25))
                }
            }*/
            Marker("My Loc",systemImage: "person" ,coordinate: .userLocation).foregroundStyle(.red.opacity(0.25))

            
            Marker("Veterans Park",systemImage: "figure.pickleball" ,coordinate: .VeteransParkLoc).tint(.blue)
            
            Marker("Reichler Park",systemImage: "figure.pickleball" ,coordinate: .ReichlerParkLoc).tint(.blue)
            
            Marker("Kingsley Park",systemImage: "figure.pickleball" ,coordinate: .KinglseyParkLoc).tint(.blue)
            
            Marker("Thompson Park",systemImage: "figure.pickleball" ,coordinate: .ThomopsonParkLoc).tint(.blue)
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
