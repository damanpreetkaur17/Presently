//
//  AppLogo.swift
//  StageReady
//

import SwiftUI

struct AppLogo: View {
    var size: CGFloat = 60
    var showText: Bool = true
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: showText ? 12 : 0) {
            // Logo icon
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Theme.primary.opacity(0.3),
                                Theme.accent.opacity(0.15),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.7
                        )
                    )
                    .frame(width: size * 1.2, height: size * 1.2)
                    .blur(radius: 8)
                    .opacity(animate ? 1 : 0.6)
                
                // Main circle with gradient
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [
                                Theme.primary,
                                Theme.accent,
                                Theme.secondary,
                                Theme.primary
                            ],
                            center: .center
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(color: Theme.primary.opacity(0.5), radius: 12, x: 0, y: 6)
                
                // Inner design - Stage curtain/wave pattern
                ZStack {
                    // Top wave
                    WaveShape(amplitude: 8, frequency: 2, phase: animate ? .pi : 0)
                        .fill(Color.white.opacity(0.9))
                        .frame(width: size * 0.6, height: size * 0.25)
                        .offset(y: -size * 0.15)
                    
                    // Middle wave
                    WaveShape(amplitude: 6, frequency: 2.5, phase: animate ? .pi * 1.5 : 0)
                        .fill(Color.white.opacity(0.7))
                        .frame(width: size * 0.6, height: size * 0.2)
                    
                    // Bottom wave
                    WaveShape(amplitude: 8, frequency: 2, phase: animate ? .pi * 0.5 : 0)
                        .fill(Color.white.opacity(0.5))
                        .frame(width: size * 0.6, height: size * 0.25)
                        .offset(y: size * 0.15)
                    
                    // Center sparkle
                    Image(systemName: "sparkles")
                        .font(.system(size: size * 0.35, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .white.opacity(0.5), radius: 4, x: 0, y: 0)
                        .scaleEffect(animate ? 1.1 : 0.9)
                }
                .clipShape(Circle())
            }
            
            // App name
            if showText {
                VStack(alignment: .leading, spacing: 2) {
                    Text("StageReady")
                        .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.textPrimary, Theme.primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Pre-Stage Warm-Up")
                        .font(.system(size: size * 0.2, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true)
            ) {
                animate = true
            }
        }
    }
}

// Custom wave shape for logo
struct WaveShape: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin(relativeX * frequency * .pi * 2 + phase)
            let y = midHeight + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// Compact logo variant for navigation bar
struct CompactAppLogo: View {
    var size: CGFloat = 32
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(Theme.primary.opacity(0.2))
                .frame(width: size * 1.3, height: size * 1.3)
                .blur(radius: 6)
                .opacity(pulse ? 1 : 0.5)
            
            // Main circle
            Circle()
                .fill(Theme.heroCircleGradient)
                .frame(width: size, height: size)
                .shadow(color: Theme.primary.opacity(0.4), radius: 8, x: 0, y: 4)
            
            // Icon
            Image(systemName: "sparkles")
                .font(.system(size: size * 0.5, weight: .bold))
                .foregroundStyle(.white)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                pulse = true
            }
        }
    }
}

#Preview("Full Logo") {
    ZStack {
        Color.black
        AppLogo(size: 80, showText: true)
    }
}

#Preview("Icon Only") {
    ZStack {
        Color.black
        AppLogo(size: 60, showText: false)
    }
}

#Preview("Compact Logo") {
    ZStack {
        Color.black
        CompactAppLogo(size: 40)
    }
}
