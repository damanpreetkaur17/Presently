//
//  TongueTwisters.swift
//  StageReady
//

import Foundation

enum TongueTwisters {
    static let list = [
        "She sells seashells by the seashore.",
        "How much wood would a woodchuck chuck?",
        "Peter Piper picked a peck of pickled peppers.",
        "Red lorry, yellow lorry.",
        "Unique New York, New York's unique.",
        "Six sticky skeletons.",
        "Which witch switched the Swiss wristwatches?",
        "Friendly Frank flips fine flapjacks.",
    ]

    static var random: String { list.randomElement() ?? list[0] }
}
