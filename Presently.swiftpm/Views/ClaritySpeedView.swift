//
//  ClaritySpeedView.swift
//  StageReady
//

import SwiftUI

struct ClaritySpeedView: View {
    @ObservedObject var session: SessionState
    @StateObject private var viewModel = ClaritySpeedViewModel()
    @State private var pulse = false

    var body: some View {
        ZStack {
            AnimatedBackground()
                .overlay(floatingLight, alignment: .top)

            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: geometry.size.height * 0.12)
                        
                        VStack(spacing: 32) {
                            if viewModel.phase == .result, let res = viewModel.result {
                                resultView(res)
                                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                            } else {
                                mainView
                                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                            }
                        }
                        
                        Spacer(minLength: geometry.size.height * 0.12)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Clarity Speed")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadTwister() }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) { pulse = true }
        }
        .onDisappear {
            // Reset navigation when leaving view
            if session.currentChallenge == .claritySpeed {
                session.navigateTo(nil)
            }
        }
    }

    private var mainView: some View {
        VStack(spacing: 32) {
            Image(systemName: "text.bubble")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(Theme.primary.opacity(0.7))
            
            VStack(spacing: 12) {
                Text("Read the tongue twister")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                
                Text("Speak clearly at a steady pace")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            GlassPanel {
                Text(viewModel.tongueTwister)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.vertical, 8)
            }

            if viewModel.phase == .ready {
                VStack(spacing: 16) {
                    Text("Tap Start, read aloud, then tap Stop")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Theme.mutedTextColor)
                    GlowButton(title: "Start Reading", icon: "play.fill", action: {
                        viewModel.startTimer()
                    })
                }
            } else {
                VStack(spacing: 20) {
                    GlowingTimerRing(elapsed: viewModel.elapsed)
                    GlowButton(title: "Stop", icon: "stop.fill", action: {
                        viewModel.stopTimer()
                    }, style: .secondary)
                }
            }
        }
    }

    private func resultView(_ res: ClaritySpeedViewModel.Result) -> some View {
        VStack(spacing: 36) {
            let (color, icon) = feedbackStyle(res.feedback)
            
            // Animated feedback icon with glow
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .blur(radius: 15)
                
                Image(systemName: icon)
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 20) {
                Text("Reading Time")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1.5)
                
                // Large time display with animated gauge
                ZStack {
                    // Background gauge track
                    Circle()
                        .stroke(Theme.subtleDivider.opacity(0.3), lineWidth: 12)
                        .frame(width: 200, height: 200)
                    
                    // Animated gauge arc (5-8 sec is optimal)
                    Circle()
                        .trim(from: 0, to: min(1.0, res.duration / 15.0))
                        .stroke(
                            AngularGradient(
                                colors: [color, color.opacity(0.6)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: res.duration)
                        .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: 0)
                    
                    // Time in center
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", res.duration))
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.primary)
                            Text("s")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            
            feedbackBadge(res.feedback)
            
            // Target range indicator
            VStack(spacing: 10) {
                Text("Target Range")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.mutedTextColor)
                    .textCase(.uppercase)
                    .tracking(0.8)
                
                HStack(spacing: 12) {
                    ForEach([5.0, 6.0, 7.0, 8.0], id: \.self) { sec in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(res.duration >= sec - 0.5 && res.duration <= sec + 0.5 ? Theme.success : Theme.subtleDivider)
                                .frame(width: 8, height: 8)
                            Text("\(Int(sec))")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.mutedTextColor)
                        }
                    }
                }
                
                Text("5–8 seconds for steady clarity")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            GlowButton(title: "Done", icon: "checkmark", action: {
                session.markCompleted(.claritySpeed)
                session.navigateTo(nil)
            })
        }
    }

    private func feedbackBadge(_ f: ClaritySpeedViewModel.Feedback) -> some View {
        let (color, icon) = feedbackStyle(f)
        return HStack(spacing: 8) {
            Image(systemName: icon)
            Text(f.rawValue)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule().stroke(color.opacity(0.28), lineWidth: 1)
        )
        .clipShape(Capsule())
    }

    private func feedbackStyle(_ f: ClaritySpeedViewModel.Feedback) -> (Color, String) {
        switch f {
        case .steady: return (Theme.success, "checkmark.circle.fill")
        case .slightlyFast, .slightlySlow: return (Theme.warning, "exclamationmark.circle.fill")
        case .tooRushed, .tooSlow: return (Theme.error, "xmark.circle.fill")
        }
    }

    private var floatingLight: some View {
        GeometryReader { geo in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Theme.accent.opacity(0.18),
                            Theme.primary.opacity(0.10),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 420, height: 420)
                .position(x: geo.size.width * (pulse ? 0.72 : 0.28), y: 60)
                .blur(radius: 2)
                .opacity(0.95)
                .allowsHitTesting(false)
                .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: pulse)
        }
        .ignoresSafeArea()
        .blendMode(.plusLighter)
    }
}

private struct GlowingTimerRing: View {
    let elapsed: TimeInterval
    @State private var breathe = false

    var body: some View {
        ZStack {
            // Enhanced pulsing glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Theme.accentGlowColor.opacity(0.35),
                            Theme.haloGlow.opacity(0.12),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 130
                    )
                )
                .frame(width: 200, height: 200)
                .opacity(breathe ? 1 : 0.75)
                .scaleEffect(breathe ? 1.04 : 0.97)

            ProgressRing(progress: elapsed, totalSeconds: 15, lineWidth: 12)
                .frame(width: 150, height: 150)
                .shadow(color: Theme.primary.opacity(0.45), radius: 20, x: 0, y: 14)

            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 122, height: 122)
                .overlay(Circle().stroke(Theme.subtleDivider, lineWidth: 1))

            Text(String(format: "%.1fs", elapsed))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { breathe = true }
        }
    }
}

private struct GlassPanel<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.26), Color.white.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 26, x: 0, y: 18)
    }
}

#Preview {
    NavigationStack {
        ClaritySpeedView(session: SessionState())
    }
}
