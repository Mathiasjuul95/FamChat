//
//  ChatDetailView.swift
//  FamChat
//
//  Created by Mathias Juul on 08/07/2025.
//

import SwiftUI

struct ChatDetailView: View {
    let chatTitle: String
    @State private var messageText: String = ""
    @State private var messages: [String] = [
        "Hei! Hvordan går det?",
        "Alt bra her. Med deg?"
    ]

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { msg in
                        Text(msg)
                    
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                TextField("Skriv en melding...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    if !messageText.isEmpty {
                        messages.append(messageText)
                        messageText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle(chatTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
