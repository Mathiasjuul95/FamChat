//
//  MainAppView.swift
//  FamChat
//
//  Created by Mathias Juul on 08/07/2025.
//

import SwiftUI

struct MainAppView: View {
    @State private var showAccount = false

    var body: some View {
        NavigationStack {
            ChatListView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showAccount = true
                        }) {
                            Image(systemName: "person.crop.circle")
                        }
                    }
                }
                .sheet(isPresented: $showAccount) {
                    AccountView()
                }
        }
    }
}



