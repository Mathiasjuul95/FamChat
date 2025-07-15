//
//  ChatListView.swift
//  FamChat
//
//  Created by Mathias Juul on 07/07/2025.
//

import SwiftUI

struct ChatListView: View {
    let chats = ["Test Chat", "Fam Chat", "Work Chat"]

    var body: some View {
        List(chats, id: \.self) { chat in
            NavigationLink(destination: ChatDetailView(chatTitle: chat)) {
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundColor(.blue)
                    Text(chat)
                }
            }
        }
        .navigationTitle("FamChat")
    }
}
