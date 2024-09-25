//
//  ContentView.swift
//  PicklePlaySB V1
//
//  Created by ganeshan venu and chunginator supreme on 8/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
