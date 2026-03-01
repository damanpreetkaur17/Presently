//
//  EyeFocusViewModel.swift
//  StageReady
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class EyeFocusViewModel: ObservableObject {
    @Published var phase: Phase = .waiting
    @Published var scale: CGFloat = 0.3
    @Published var tapTime: Date?
    @Published var peakTime: Date?
    @Published var score: Double = 0
    @Published var round: Int = 0
    @Published var lastDifference: TimeInterval = 0

    private let expandDuration: TimeInterval = 2.5
    private var expandStart: Date?
    private var peakReached = false

    static let rounds = 3

    enum Phase {
        case waiting
        case expanding
        case tapped
        case result
    }

    func startRound() {
        round += 1
        phase = .expanding
        scale = 0.3
        tapTime = nil
        peakTime = nil
        peakReached = false
        expandStart = Date()
    }

    func updateScale(currentTime: Date) {
        guard phase == .expanding, let start = expandStart else { return }
        let elapsed = currentTime.timeIntervalSince(start)
        if elapsed >= expandDuration {
            scale = 1.0
            if !peakReached {
                peakReached = true
                peakTime = start.addingTimeInterval(expandDuration)
            }
        } else {
            scale = 0.3 + 0.7 * CGFloat(elapsed / expandDuration)
        }
    }

    func recordTap(at time: Date) {
        guard phase == .expanding else { return }
        tapTime = time
        if peakTime == nil { peakTime = expandStart?.addingTimeInterval(expandDuration) ?? time }
        lastDifference = abs(time.timeIntervalSince(peakTime ?? time))
        score = max(0, 100 - lastDifference * 40)
        phase = .tapped
    }

    func showResult() {
        phase = .result
    }

    func totalScore(roundScores: [Double]) -> Double {
        guard !roundScores.isEmpty else { return 0 }
        return roundScores.reduce(0, +) / Double(roundScores.count)
    }

    func reset() {
        phase = .waiting
        round = 0
        score = 0
    }
}
