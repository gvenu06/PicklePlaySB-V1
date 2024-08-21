//
//  ContentView.swift
//  PicklePlaySB V1
//
//  Created by ganeshan venu on 8/13/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager.shared
    var body: some View {
        /*Group {
            if locationManager.userLocation == nil{
                LocationRequestView()
                }
            else {
                Text("Hello, world!")
                    .padding()
            }
        }*/
        TabView{
            FindView()
                .tabItem{
                    Image(systemName: "magnifyingglass")
                    Text("Find")
                }
            QueueView()
                .tabItem{
                    Image(systemName:"person.3.fill")
                    Text("Queue")
                }
            ProfileView()
                .tabItem {
                    Image(systemName:"person.circle")
                    Text("Profile")
                }
        }
     
    }
}

#Preview {
    ContentView()
}
