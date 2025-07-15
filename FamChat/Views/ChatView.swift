//
//  ChatView.swift
//  FamChat
//
//  Created by Mathias Juul on 07/07/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [Message] = []
    let chatID: String
    let chatService = ChatService()

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(messages) { msg in
                            MessageRow(
                                message: msg,
                                isCurrentUser: msg.senderID == Auth.auth().currentUser?.uid,
                                onTap: {
                                    if let id = msg.id,
                                       msg.senderID == Auth.auth().currentUser?.uid,
                                       (msg.isSaved ?? false) == false {
                                        chatService.markMessageAsSaved(chatID: chatID, messageID: id)
                                    }
                                }
                            )
                            .id(msg.id)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: messages.count) { oldCount, newCount in
                    if oldCount != newCount, let last = messages.last?.id {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack {
                TextField("Skriv melding", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    sendMessage()
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .onAppear {
            chatService.listenForMessages(chatID: chatID) { msgs in
                self.messages = msgs
            }
        }
    }

    func sendMessage() {
        guard !messageText.isEmpty else { return }
        chatService.sendMessage(chatID: chatID, text: messageText) { error in
            if error == nil {
                messageText = ""
            }
        }
    }
}



