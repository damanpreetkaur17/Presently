//
//  AudioMetering.swift
//  StageReady
//

import AVFoundation
import SwiftUI
import Combine

@MainActor
final class AudioMetering: NSObject, ObservableObject {

    @Published var currentLevel: Float = -160
    @Published var smoothedLevel: Float = -160
    @Published var isRecording = false

    private var recorder: AVAudioRecorder?
    private var timer: Timer?

    private let smoothing: Float = 0.3
    private let targetLow: Float = -25
    private let targetHigh: Float = -15

    var isInTargetZone: Bool {
        smoothedLevel >= targetLow && smoothedLevel <= targetHigh
    }

    var isTooLoud: Bool { smoothedLevel > targetHigh }
    var isTooSoft: Bool { smoothedLevel < targetLow && smoothedLevel > -100 }

    // 🔥 FIXED: removed nonisolated
    func requestPermissionAndStart() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
            guard allowed, let self = self else { return }
            Task { @MainActor in
                self.startRecording()
            }
        }
    }

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord,
                                 mode: .default,
                                 options: [.defaultToSpeaker])
        try? session.setActive(true)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("stage_ready_meter.caf")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]

        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.isMeteringEnabled = true
        recorder?.record()

        isRecording = true

        timer = Timer.scheduledTimer(withTimeInterval: 0.05,
                                     repeats: true) { [weak self] _ in
            self?.updateMeter()
        }
    }

    private func updateMeter() {
        recorder?.updateMeters()
        let peak = recorder?.averagePower(forChannel: 0) ?? -160

        currentLevel = peak
        smoothedLevel = smoothedLevel + (peak - smoothedLevel) * smoothing
    }

    func stopRecording() {
        timer?.invalidate()
        timer = nil

        recorder?.stop()
        recorder = nil

        isRecording = false
        currentLevel = -160
        smoothedLevel = -160
    }
}
