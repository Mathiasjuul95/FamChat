//
//  MessageRow.swift
//  FamChat
//
//  Created by Mathias Juul on 10/07/2025.
//

import SwiftUI
import AVFoundation

struct MessageRow: View {
    let message: Message
    let isCurrentUser: Bool
    var onTap: (() -> Void)? = nil

    @State private var audioPlayer: AVPlayer?
    @State private var isPlaying = false

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: .leading, spacing: 4) {
                // 👇 BILDE
                if let imageURL = message.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 200, height: 150)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: 250, maxHeight: 200)
                                .clipped()
                                .cornerRadius(10)
                        case .failure:
                            Text("Kunne ikke laste bilde")
                                .foregroundColor(.red)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // 👇 LYD
                if let audioURL = message.audioURL {
                    Button(action: {
                        toggleAudioPlayback(url: audioURL)
                    }) {
                        HStack {
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            Text(isPlaying ? "Stop" : "Spill av lyd")
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }

                // 👇 TEKST
                if let text = message.text, !text.isEmpty {
                    Text(text)
                        .padding(10)
                        .background(isCurrentUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.primary)
                }
            }
            .padding(8)
            .background(
                isCurrentUser ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1)
            )
            .cornerRadius(12)
            .onTapGesture {
                onTap?()
            }

            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }

    private func toggleAudioPlayback(url: String) {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            guard let audioURL = URL(string: url) else { return }
            audioPlayer = AVPlayer(url: audioURL)
            audioPlayer?.play()
            isPlaying = true

            // Stop when done
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem, queue: .main) { _ in
                isPlaying = false
            }
        }
    }
}

