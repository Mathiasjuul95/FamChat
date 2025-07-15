//
//  ChatService.swift
//  FamChat
//
//  Created by Mathias Juul on 07/07/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ChatService {
    private let db = Firestore.firestore()
    
    func sendMessage(chatID: String, text: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let message = Message(id: nil, text: text, senderID: userID, timestamp: Date(), isSaved: false)

        do {
            _ = try db.collection("chats").document(chatID)
                .collection("messages").addDocument(from: message, completion: { error in
                    completion(error)
                })
        } catch {
            completion(error)
        }
    }
    
    func listenForMessages(chatID: String, onUpdate: @escaping ([Message]) -> Void) {
        db.collection("chats").document(chatID)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let now = Date()

                let messages = documents.compactMap { doc -> Message? in
                    guard var msg = try? doc.data(as: Message.self) else { return nil }

                    // 🕒 Slett gamle meldinger hvis ikke lagret
                    if !(msg.isSaved ?? false), now.timeIntervalSince(msg.timestamp) > 86400 {
                        doc.reference.delete()
                        return nil
                    }

                    return msg
                }

                onUpdate(messages)
            }
    }

    func markMessageAsSaved(chatID: String, messageID: String) {
        let ref = db.collection("chats").document(chatID).collection("messages").document(messageID)
        ref.updateData(["isSaved": true])
    }
}


