//
//  Message.swift
//  FamChat
//
//  Created by Mathias Juul on 07/07/2025.
//

import Foundation
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
        let text: String?
        let senderID: String
        let timestamp: Date
        var isSaved: Bool?
        var imageURL: String?
        var audioURL: String?
}
