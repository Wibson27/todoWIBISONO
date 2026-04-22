//
//  todoWIBISONOApp.swift
//  todoWIBISONO
//
//  Created by 22 on 2026/4/21.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct todoWIBISONOApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // @StateObject — this view creates and owns AuthViewModel for the entire app lifetime
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
        }
    }
}
