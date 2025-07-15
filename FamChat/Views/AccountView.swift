//
//  AccountView.swift
//  FamChat
//
//  Created by Mathias Juul on 08/07/2025.
//

import SwiftUI
import FirebaseAuth

struct AccountView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
            Text(Auth.auth().currentUser?.email ?? "Ukjent")
            Button("Logg ut") {
                try? Auth.auth().signOut()
                appState.isLoggedIn = false
            }
            .foregroundColor(.red)
            Spacer()
        }
        .padding()
    }
}
