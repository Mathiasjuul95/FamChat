//
//  UserService.swift
//  FamChat
//
//  Created by Mathias Juul on 09/07/2025.
//

import FirebaseFirestore

struct UserProfile: Identifiable {
    let id: String
    let name: String
    let email: String
}

class UserService {
    private let db = Firestore.firestore()

    func fetchUser(uid: String, completion: @escaping (UserProfile?) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("❌ Firestore-feil ved henting av bruker \(uid): \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                print("⚠️ Ingen dokument funnet for bruker med UID: \(uid)")
                completion(nil)
                return
            }

            guard
                let data = snapshot.data(),
                let name = data["name"] as? String,
                let email = data["email"] as? String
            else {
                print("⚠️ Manglende eller ugyldige data for bruker med UID: \(uid)")
                print("📦 Rådata: \(snapshot.data() ?? [:])")
                completion(nil)
                return
            }

            let user = UserProfile(id: uid, name: name, email: email)
            completion(user)
        }
    }

    func addFamMember(for currentUserID: String, famUserID: String, completion: @escaping (Error?) -> Void) {
        let ref = db.collection("users").document(currentUserID).collection("fam").document(famUserID)
        ref.setData(["addedAt": Date()]) { error in
            completion(error)
        }
    }
    
    func searchUsers(query: String, completion: @escaping ([UserProfile]) -> Void) {
        db.collection("users")
            .whereField("keywords", arrayContains: query.lowercased())
            .limit(to: 10)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Feil ved søk: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let users = snapshot?.documents.compactMap { doc -> UserProfile? in
                    let data = doc.data()
                    guard let name = data["fullName"] as? String,
                          let email = data["email"] as? String else {
                        return nil
                    }
                    return UserProfile(id: doc.documentID, name: name, email: email)
                } ?? []

                completion(users)
            }
    }
    func fetchFamMembers(for userID: String, completion: @escaping ([String]) -> Void) {
        db.collection("users").document(userID).collection("fam").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                let ids = documents.map { $0.documentID }
                completion(ids)
            } else {
                completion([])
            }
        }
    }
}

