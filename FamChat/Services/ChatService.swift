//
//  ChatService.swift
//  FamChat
//
//  Created by Mathias Juul on 07/07/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestoreSwift
import UIKit



class ChatService {
    private let db = Firestore.firestore()
    
    func sendMessage(chatID: String, text: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let message = Message(id: nil, text: text, senderID: userID, timestamp: Date(), isSaved: false)
        
        do {
            try db.collection("chats").document(chatID)
                .collection("messages")
                .addDocument(from: message, completion: { error in
                    completion(error)
                })
        } catch {
            completion(error)
        }

    }
    
    func sendMessageWithImageAndText(chatID: String, text: String, imageURL: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "ChatService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bruker ikke logget inn"]))
            return
        }

        let message = Message(
            id: nil,
            text: text,
            senderID: userID,
            timestamp: Date(),
            isSaved: false,
            imageURL: imageURL
        )

        do {
            try db.collection("chats").document(chatID)
                .collection("messages")
                .addDocument(from: message) { error in
                    completion(error)
                }
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

    func uploadAudio(_ fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = Storage.storage().reference().child("audio/\(UUID().uuidString).m4a")
        ref.putFile(from: fileURL, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            ref.downloadURL { url, error in
                if let url = url {
                    completion(.success(url.absoluteString))
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }

    func sendAudioMessage(chatID: String, audioURL: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let message = Message(id: nil, text: "", senderID: userID, timestamp: Date(), isSaved: false, audioURL: audioURL)

        do {
            try db.collection("chats").document(chatID)
                .collection("messages")
                .addDocument(from: message) { error in
                    completion(error)
                }
        } catch {
            completion(error)
        }

    }

    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let resized = image.resized(to: CGSize(width: 800, height: 800))
        guard let imageData = resized.jpegData(compressionQuality: 0.8) else { return }
        
        let ref = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            ref.downloadURL { url, error in
                if let url = url {
                    completion(.success(url.absoluteString))
                } else if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }

    func sendImageMessage(chatID: String, imageURL: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let message = Message(id: nil, text: "", senderID: userID, timestamp: Date(), isSaved: false, imageURL: imageURL)
        
        do {
            try db.collection("chats").document(chatID)
                .collection("messages")
                .addDocument(from: message) { error in
                    completion(error)
                }
        } catch {
            completion(error)
        }

    }
}
