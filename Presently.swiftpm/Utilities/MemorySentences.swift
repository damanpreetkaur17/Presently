//
//  MemorySentences.swift
//  StageReady
//

import Foundation

enum MemorySentences {
    static let list = [
        "The quick brown fox jumps over the lazy dog.",
        "Success is the sum of small efforts repeated day in and day out.",
        "Your mind is a garden; your thoughts are the seeds.",
        "Confidence comes from discipline and preparation.",
        "The best way to predict the future is to create it.",
    ]

    static var random: String { list.randomElement() ?? list[0] }
}
