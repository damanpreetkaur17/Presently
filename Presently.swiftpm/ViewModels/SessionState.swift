//
//  SessionState.swift
//  StageReady
//

import SwiftUI
import Combine

enum ChallengeId: String, CaseIterable, Identifiable {
    case matchWave
    case claritySpeed
    case eyeFocus
    case memorySpark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .matchWave: return "Match the Wave"
        case .claritySpeed: return "Clarity Speed"
        case .eyeFocus: return "Eye Focus"
        case .memorySpark: return "Memory Spark"
        }
    }

    var subtitle: String {
        switch self {
        case .matchWave: return "Voice control • 20 sec"
        case .claritySpeed: return "Tongue twister • ~5–8 sec"
        case .eyeFocus: return "Tap at peak"
        case .memorySpark: return "Recall sentence"
        }
    }

    var icon: String {
        switch self {
        case .matchWave: return "waveform"
        case .claritySpeed: return "speaker.wave.2"
        case .eyeFocus: return "eye"
        case .memorySpark: return "brain.head.profile"
        }
    }
}

@MainActor
final class SessionState: ObservableObject {
    static let totalSessionSeconds: Double = 180

    @Published var elapsedSeconds: Double = 0
    @Published var completedChallenges: Set<ChallengeId> = []
    @Published var currentChallenge: ChallengeId?
    @Published var sessionStartTime: Date?

    var progress: Double { min(1, elapsedSeconds / Self.totalSessionSeconds) }
    var isSessionActive: Bool { sessionStartTime != nil }

    func startSession() {
        sessionStartTime = Date()
        elapsedSeconds = 0
    }

    func tick() {
        guard let start = sessionStartTime else { return }
        elapsedSeconds = Date().timeIntervalSince(start)
    }

    func markCompleted(_ id: ChallengeId) {
        completedChallenges.insert(id)
    }

    func navigateTo(_ id: ChallengeId?) {
        currentChallenge = id
    }

    func endSession() {
        sessionStartTime = nil
        currentChallenge = nil
        completedChallenges.removeAll()
        elapsedSeconds = 0
    }
}
