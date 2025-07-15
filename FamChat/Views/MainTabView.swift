//
//  MainTabView.swift
//  FamChat
//
//  Created by Mathias Juul on 08/07/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var showAccountSheet = false

    var body: some View {
        TabView {
            NavigationStack {
                ChatListView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showAccountSheet = true
                            }) {
                                Image(systemName: "person.crop.circle")
                            }
                        }
                    }
            }
            .tabItem {
                Label("Chats", systemImage: "message.fill")
            }

            NavigationStack {
                AddFamView()
            }
            .tabItem {
                Label("Legg til Fam", systemImage: "person.badge.plus")
            }

            NavigationStack {
                AccountView()
            }
            .tabItem {
                Label("Profil", systemImage: "person.crop.circle")
            }
        }
        .sheet(isPresented: $showAccountSheet) {
            AccountView()
        }
    }
}

