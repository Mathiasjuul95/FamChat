//
//  LoginView.swift
//  FamChat
//
//  Created by Mathias Juul on 07/07/2025.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Logg inn") {
                login()
            }
            .padding()

            NavigationLink("Ingen konto? Registrer deg", destination: RegisterView())
        }
        .padding()
        .navigationTitle("Logg inn")
        .alert("Feil", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                appState.isLoggedIn = true
            }
        }
    }
}
