//
//  FamChatApp.swift
//  FamChat
//
//  Created by Mathias Juul on 08/07/2025.
//

import SwiftUI
import Firebase
import UIKit

// 📌 AppDelegate som håndterer Firebase init
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct FamChatApp: App {
    @StateObject private var appState = AppState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                NavigationStack {
                    MainTabView()
                        .environmentObject(appState)
                }
            } else {
                NavigationStack {
                    LoginView()
                        .environmentObject(appState)
                }
            }
        }
    }
}




