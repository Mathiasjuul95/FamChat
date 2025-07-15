//
//  AppState.swift
//  FamChat
//
//  Created by Mathias Juul on 08/07/2025.
//


import FirebaseAuth

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        // Forsink initiering til Firebase er konfigurert
        DispatchQueue.main.async {
            self.isLoggedIn = Auth.auth().currentUser != nil
            print("AppState: Bruker er logget inn? \(self.isLoggedIn)")
        }
    }
}
