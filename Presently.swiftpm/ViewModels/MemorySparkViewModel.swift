//
//  MemorySparkViewModel.swift
//  StageReady
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class MemorySparkViewModel: ObservableObject {
    @Published var phase: Phase = .showSentence
    @Published var sentence: String = ""
    @Published var typedText: String = ""
    @Published var result: Result?
    @Published var puzzleNumber: Int = 0
    @Published var puzzleCorrect: Bool = false
    @Published var puzzleQuestion: String = ""

    static let showDuration: TimeInterval = 4
    static let puzzleDuration: TimeInterval = 5

    enum Phase {
        case showSentence
        case hide
        case puzzle
        case recall
        case result
    }

    struct Result {
        let score: Score
        let correctWords: Int
        let totalWords: Int
        let wrongWordIndices: Set<Int>
    }

    enum Score: String {
        case strongRecall = "Strong Recall"
        case smallGaps = "Small Gaps"
        case reviewAgain = "Review Again"
    }

    func loadSentence() {
        sentence = MemorySentences.random
        typedText = ""
        result = nil
        phase = .showSentence
        puzzleNumber = Int.random(in: 10...99)
        puzzleCorrect = false
        puzzleQuestion = ""
    }

    func startPuzzle() {
        phase = .puzzle
        puzzleNumber = Int.random(in: 10...99)
        generatePuzzle()
    }

    func checkPuzzle(_ answer: Int) {
        let correct = expectedPuzzleAnswer()
        puzzleCorrect = answer == correct
    }

    func computeResult() {
        let originalWords = sentence.lowercased().split(separator: " ").map(String.init)
        let typedWords = typedText.lowercased().split(separator: " ").map(String.init)
        var wrongIndices: Set<Int> = []
        var correctCount = 0
        for (i, orig) in originalWords.enumerated() {
            let typed = i < typedWords.count ? typedWords[i] : ""
            if orig == typed {
                correctCount += 1
            } else {
                wrongIndices.insert(i)
            }
        }
        let ratio = originalWords.isEmpty ? 0 : Double(correctCount) / Double(originalWords.count)
        let score: Score
        if ratio >= 0.9 { score = .strongRecall }
        else if ratio >= 0.6 { score = .smallGaps }
        else { score = .reviewAgain }
        result = Result(score: score, correctWords: correctCount, totalWords: originalWords.count, wrongWordIndices: wrongIndices)
        phase = .result
    }

    // MARK: - Puzzle generation

    private func generatePuzzle() {
        // Slightly more “confusing” than simple digit addition, but still quick.
        // Example: 3 × 7 + 3  or  5 × 6 − 5
        let a = Int.random(in: 3...9)
        let b = Int.random(in: 2...9)
        let usePlus = Bool.random()
        puzzleNumber = a * 10 + b
        if usePlus {
            puzzleQuestion = "\(a) × \(b) + \(a)"
        } else {
            puzzleQuestion = "\(a) × \(b) − \(a)"
        }
    }

    private func expectedPuzzleAnswer() -> Int {
        // Decode from current puzzleQuestion
        // Format guaranteed by generatePuzzle()
        let comps = puzzleQuestion.split(separator: " ")
        guard comps.count == 5,
              let a = Int(comps[0]),
              let b = Int(comps[2]),
              let c = Int(comps[4]) else {
            return 0
        }
        if comps[3] == "+" {
            return a * b + c
        } else {
            return a * b - c
        }
    }
}
