//
//  PicklePlaySB_V1App.swift
//  PicklePlaySB V1
//
//  Created by ganeshan venu on 8/13/24.
//

import SwiftUI
import Firebase
@main
struct PicklePlaySB_V1App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
