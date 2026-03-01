//
//  ProgressRing.swift
//  StageReady
//

import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let totalSeconds: Double
    let lineWidth: CGFloat
    var animated: Bool = true

    private var displayProgress: Double {
        min(1, max(0, progress / totalSeconds))
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Theme.subtleDivider, lineWidth: lineWidth)

            // Animated progress with gradient
            Circle()
                .trim(from: 0, to: animated ? displayProgress : 0)
                .stroke(
                    Theme.ringGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.85), value: displayProgress)
                .shadow(color: Theme.primary.opacity(0.45), radius: 8, x: 0, y: 0)
        }
    }
}

#Preview {
    ProgressRing(progress: 90, totalSeconds: 180, lineWidth: 10)
        .frame(width: 120, height: 120)
}
