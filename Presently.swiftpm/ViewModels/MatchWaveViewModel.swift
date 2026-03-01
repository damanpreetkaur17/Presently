//
//  MatchWaveViewModel.swift
//  StageReady
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class MatchWaveViewModel: ObservableObject {
    static let duration: TimeInterval = 20

    @Published var phase: Phase = .idle
    @Published var remainingSeconds: Double = MatchWaveViewModel.duration
    @Published var samples: [Float] = []
    @Published var stabilityScores: [Double] = [] // per-segment stability 0...1

    private var timer: Timer?
    private var startDate: Date?
    private let segmentCount = 10
    private var segmentSamples: [[Float]] = []

    enum Phase {
        case idle
        case recording
        case result
    }

    func startRecording() {
        phase = .recording
        remainingSeconds = Self.duration
        samples = []
        stabilityScores = []
        segmentSamples = Array(repeating: [], count: segmentCount)
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    func addSample(_ level: Float) {
        guard phase == .recording else { return }
        let normalized = (level + 60) / 60
        let clamped = min(1, max(0, normalized))
        samples.append(clamped)
        if samples.count > 120 { samples.removeFirst() }

        let progress = 1 - (remainingSeconds / Self.duration)
        let segmentIndex = min(segmentCount - 1, Int(progress * Double(segmentCount)))
        if segmentIndex >= 0, segmentIndex < segmentSamples.count {
            segmentSamples[segmentIndex].append(level)
        }
    }

    private func tick() {
        guard let start = startDate else { return }
        let elapsed = Date().timeIntervalSince(start)
        remainingSeconds = max(0, Self.duration - elapsed)
        if remainingSeconds <= 0 {
            stopAndComputeResult()
        }
    }

    func stopAndComputeResult() {
        timer?.invalidate()
        timer = nil
        startDate = nil

        var anySamples = false
        for i in 0..<segmentCount {
            let seg = segmentSamples[i]
            if seg.isEmpty {
                stabilityScores.append(0)
            } else {
                anySamples = true
                let targetLow: Float = -25
                let targetHigh: Float = -15
                let inZone = seg.filter { $0 >= targetLow && $0 <= targetHigh }.count
                stabilityScores.append(Double(inZone) / Double(max(1, seg.count)))
            }
        }

        // If we never received any audio samples (permission denied / no speech),
        // show a subtle baseline so the chart is not visually empty.
        if !anySamples || stabilityScores.allSatisfy({ $0 == 0 }) {
            stabilityScores = Array(repeating: 0.1, count: segmentCount)
        }

        phase = .result
    }

    func reset() {
        phase = .idle
        remainingSeconds = Self.duration
        samples = []
        stabilityScores = []
    }
}
