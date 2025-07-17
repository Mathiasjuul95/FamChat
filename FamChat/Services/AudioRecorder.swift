//
//  AudioRecorder.swift
//  FamChat
//
//  Created by Mathias Juul on 17/07/2025.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    private var recorder: AVAudioRecorder?
    private let filename = UUID().uuidString + ".m4a"

    func startRecording() {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: path, settings: settings)
            recorder?.record()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        recorder?.stop()
        let url = recorder?.url
        completion(url)
        recorder = nil
    }
}
