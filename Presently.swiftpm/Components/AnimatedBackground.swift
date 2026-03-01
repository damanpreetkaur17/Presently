//
//  AnimatedBackground.swift
//  StageReady
//

import SwiftUI

struct AnimatedBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            // Deep cinematic base gradient
            Theme.mainBackgroundGradient
                .ignoresSafeArea()

            // Animated mesh glow orbs
            GeometryReader { geo in
                let size = geo.size
                ForEach(0..<3, id: \.self) { i in
                    let angle = phase + CGFloat(i) * (.pi * 2 / 3)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Theme.accentGlowColor.opacity(0.35),
                                    Theme.haloGlow.opacity(0.18),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 340, height: 340)
                        .blur(radius: 50)
                        .offset(
                            x: size.width * (0.20 + 0.30 * cos(angle)),
                            y: size.height * (0.25 + 0.25 * sin(angle * 0.85))
                        )
                        .opacity(0.75)
                        .blendMode(.plusLighter)
                }
            }
            .ignoresSafeArea()

            // Soft depth vignette
            RadialGradient(
                colors: [
                    Color.clear,
                    Theme.softShadow.opacity(0.45)
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            .blendMode(.multiply)
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}

#Preview {
    AnimatedBackground()
}
