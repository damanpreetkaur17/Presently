//
//  ClaritySpeedViewModel.swift
//  StageReady
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ClaritySpeedViewModel: ObservableObject {
    @Published var phase: Phase = .ready
    @Published var tongueTwister: String = ""
    @Published var elapsed: TimeInterval = 0
    @Published var result: Result?

    private var startTime: Date?
    private var timer: Timer?

    enum Phase {
        case ready
        case speaking
        case result
    }

    struct Result {
        let duration: TimeInterval
        let feedback: Feedback
    }

    enum Feedback: String {
        case steady = "Steady"
        case slightlyFast = "Slightly Fast"
        case slightlySlow = "Slightly Slow"
        case tooRushed = "Too Rushed"
        case tooSlow = "Too Slow"
    }

    func loadTwister() {
        tongueTwister = TongueTwisters.random
        phase = .ready
        result = nil
    }

    func startTimer() {
        phase = .speaking
        startTime = Date()
        elapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            self.elapsed = Date().timeIntervalSince(start)
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        guard let start = startTime else { return }
        let duration = Date().timeIntervalSince(start)
        let feedback: Feedback
        if duration >= 5 && duration <= 8 {
            feedback = .steady
        } else if duration >= 3 && duration < 5 {
            feedback = .slightlyFast
        } else if duration > 8 && duration <= 10 {
            feedback = .slightlySlow
        } else if duration < 3 {
            feedback = .tooRushed
        } else {
            feedback = .tooSlow
        }
        result = Result(duration: duration, feedback: feedback)
        phase = .result
    }

    func reset() {
        phase = .ready
        result = nil
        loadTwister()
    }
}
