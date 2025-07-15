//
//  MessageRow.swift
//  FamChat
//
//  Created by Mathias Juul on 10/07/2025.
//

import Foundation
import SwiftUI


struct MessageRow: View {
    let message: Message
    let isCurrentUser: Bool
    let onTap: () -> Void

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            Text(message.text)
                .padding()
                .background((message.isSaved ?? false) ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    onTap()
                }

            if !isCurrentUser { Spacer() }
        }
        .padding(.vertical, 2)
    }
}
