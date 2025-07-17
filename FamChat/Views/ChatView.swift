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
    
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isSendingImage = false
    @State private var isRecording = false
    @StateObject private var audioRecorder = AudioRecorder()

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

            // 👇 BILDEFORHÅNDSVISNING
            if let selectedImage = selectedImage {
                VStack(alignment: .leading) {
                    HStack {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                        Spacer()
                        Button(action: {
                            self.selectedImage = nil
                            self.messageText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    if messageText.isEmpty {
                        Text("Legg til tekst (valgfritt)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.leading)
                    }
                }
            }

            // 👇 LYDOPPTAK-VISNING
            if isRecording {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Opptak pågår...")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .padding(.bottom, 6)
            }

            // 👇 INNSENDING + KNAPPER
            HStack(spacing: 12) {
                Button(action: {
                    showingImagePicker = true
                }) {
                    Image(systemName: "photo")
                        .font(.system(size: 22))
                }

                Button(action: {}) {
                    Image(systemName: isRecording ? "mic.circle.fill" : "mic.fill")
                        .font(.system(size: 22))
                        .foregroundColor(isRecording ? .red : .blue)
                }
                .onLongPressGesture(minimumDuration: 0.5, pressing: { isPressing in
                    if isPressing {
                        isRecording = true
                        audioRecorder.startRecording()
                    } else {
                        isRecording = false
                        audioRecorder.stopRecording { url in
                            if let url = url {
                                chatService.uploadAudio(url) { result in
                                    if case .success(let audioURL) = result {
                                        chatService.sendAudioMessage(chatID: chatID, audioURL: audioURL) { _ in }
                                    }
                                }
                            }
                        }
                    }
                }, perform: {})

                TextField("Skriv melding", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Send") {
                    if let image = selectedImage {
                        isSendingImage = true
                        chatService.uploadImage(image) { result in
                            switch result {
                            case .success(let url):
                                chatService.sendImageMessage(chatID: chatID, imageURL: url) { error in
                                    if let error = error {
                                        print("Feil ved sending av bilde: \(error)")
                                    } else if !messageText.isEmpty {
                                        chatService.sendMessage(chatID: chatID, text: messageText) { _ in }
                                    }
                                    self.selectedImage = nil
                                    self.messageText = ""
                                    self.isSendingImage = false
                                }
                            case .failure(let error):
                                print("Feil ved bildeopplasting: \(error)")
                                self.isSendingImage = false
                            }
                        }
                    } else {
                        sendMessage()
                    }
                }
                .disabled(messageText.isEmpty && selectedImage == nil)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .onAppear {
            chatService.listenForMessages(chatID: chatID) { msgs in
                self.messages = msgs
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }

    func sendMessage() {
        // Hvis bilde er valgt
        if let image = selectedImage {
            chatService.uploadImage(image) { result in
                switch result {
                case .success(let imageURL):
                    // Hvis det også er en tekstmelding
                    if !messageText.isEmpty {
                        chatService.sendMessageWithImageAndText(chatID: chatID, text: messageText, imageURL: imageURL) { error in
                            if error == nil {
                                messageText = ""
                                selectedImage = nil
                            }
                        }
                    } else {
                        // Bare bilde
                        chatService.sendImageMessage(chatID: chatID, imageURL: imageURL) { error in
                            if error == nil {
                                selectedImage = nil
                            }
                        }
                    }
                case .failure(let error):
                    print("Feil ved bildeopplasting: \(error.localizedDescription)")
                }
            }
        } else if !messageText.isEmpty {
            // Bare tekst
            chatService.sendMessage(chatID: chatID, text: messageText) { error in
                if error == nil {
                    messageText = ""
                }
            }
        }
    }

}



