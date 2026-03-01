//
//  EyeFocusView.swift
//  StageReady
//

import SwiftUI

struct EyeFocusView: View {
    @ObservedObject var session: SessionState
    @StateObject private var viewModel = EyeFocusViewModel()
    @State private var roundScores: [Double] = []
    @State private var timer: Timer?
    @State private var breathe = false
    @State private var impactFlash = false

    var body: some View {
        ZStack {
            AnimatedBackground()
                .overlay(immersiveDarkOverlay)
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Spacer(minLength: geometry.size.height * 0.15)
                    
                    VStack(spacing: 32) {
                        if viewModel.phase == .result && roundScores.count >= EyeFocusViewModel.rounds {
                            finalResultView
                        } else {
                            mainView
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: geometry.size.height * 0.15)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .navigationTitle("Eye Focus")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.reset()
            roundScores = []
            withAnimation(.easeInOut(duration: 2.3).repeatForever(autoreverses: true)) { breathe = true }
        }
        .onDisappear {
            timer?.invalidate()
            // Reset navigation when leaving view
            if session.currentChallenge == .eyeFocus {
                session.navigateTo(nil)
            }
        }
    }

    private var mainView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Image(systemName: "eye.circle")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(Theme.primary.opacity(0.7))
                
                Text("Tap when the dot reaches full size")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Test your visual timing precision")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if viewModel.phase == .waiting {
                VStack(spacing: 20) {
                    Text("Round \(viewModel.round + 1) of \(EyeFocusViewModel.rounds)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.mutedTextColor)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    GlowButton(title: "Start Round", icon: "eye", action: {
                        viewModel.startRound()
                        startExpandTimer()
                    })
                }
            } else if viewModel.phase == .expanding || viewModel.phase == .tapped {
                VStack(spacing: 20) {
                    ZStack {
                        // Enhanced halo breathing effect
                        Circle()
                            .stroke(Theme.accentGlowColor.opacity(0.35), lineWidth: 12)
                            .frame(width: 230, height: 230)
                            .blur(radius: 2)
                            .opacity(breathe ? 0.40 : 0.18)
                            .scaleEffect(breathe ? 1.08 : 0.94)

                        // Expanding target dot with gradient
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Theme.accent.opacity(0.95),
                                        Theme.primary.opacity(0.80),
                                        Theme.primary.opacity(0.25),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 90 * viewModel.scale * 2, height: 90 * viewModel.scale * 2)
                            .shadow(color: Theme.accent.opacity(0.65), radius: 26, x: 0, y: 18)
                            .shadow(color: Theme.primary.opacity(0.45), radius: 34, x: 0, y: 26)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                                    .blur(radius: 0.5)
                            )
                            .scaleEffect(impactFlash ? 1.04 : 1)
                            .contentShape(Circle())
                            .onTapGesture {
                                viewModel.recordTap(at: Date())
                                timer?.invalidate()
                                HapticManager.medium()
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) {
                                    impactFlash = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        impactFlash = false
                                    }
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)

                    if viewModel.phase == .tapped {
                        VStack(spacing: 20) {
                            scoreArc
                            
                            VStack(spacing: 6) {
                                Text("\(Int(viewModel.score)) points")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.textPrimary)
                                Text(String(format: "%.2fs timing", viewModel.lastDifference))
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            
                            if roundScores.count + 1 < EyeFocusViewModel.rounds {
                                GlowButton(title: "Next Round", icon: "arrow.right", action: {
                                    roundScores.append(viewModel.score)
                                    viewModel.phase = .waiting
                                    viewModel.startRound()
                                    startExpandTimer()
                                })
                            } else {
                                GlowButton(title: "See Result", icon: "checkmark", action: {
                                    roundScores.append(viewModel.score)
                                    viewModel.showResult()
                                })
                            }
                        }
                    }
                }
            }
        }
    }

    private func startExpandTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            viewModel.updateScale(currentTime: Date())
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    private var scoreArc: some View {
        ZStack {
            Circle()
                .stroke(Theme.subtleDivider, lineWidth: 10)
                .frame(width: 80, height: 80)
            Circle()
                .trim(from: 0, to: viewModel.score / 100)
                .stroke(
                    Theme.highlightGradient,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.score)
            Text("\(Int(viewModel.score))")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
        }
        .shadow(color: Theme.primary.opacity(0.30), radius: 18, x: 0, y: 14)
    }

    private var finalResultView: some View {
        VStack(spacing: 40) {
            let total = viewModel.totalScore(roundScores: roundScores)
            
            // Animated target icon with pulse
            ZStack {
                // Pulsing glow rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Theme.primary.opacity(0.2 - Double(i) * 0.05), lineWidth: 2)
                        .frame(width: 100 + CGFloat(i) * 30, height: 100 + CGFloat(i) * 30)
                        .scaleEffect(breathe ? 1.1 : 0.9)
                        .animation(
                            .easeInOut(duration: 2.0 + Double(i) * 0.3)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.2),
                            value: breathe
                        )
                }
                
                Circle()
                    .fill(Theme.primary.opacity(0.15))
                    .frame(width: 90, height: 90)
                    .blur(radius: 15)
                
                Image(systemName: "target")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.primary, Theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 20) {
                Text("Focus Accuracy")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1.5)
                
                // Animated circular progress with score
                ZStack {
                    // Background track
                    Circle()
                        .stroke(Theme.subtleDivider.opacity(0.3), lineWidth: 18)
                        .frame(width: 180, height: 180)
                    
                    // Animated progress arc
                    Circle()
                        .trim(from: 0, to: total / 100)
                        .stroke(
                            Theme.ringGradient,
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.0, dampingFraction: 0.7), value: total)
                        .shadow(color: Theme.primary.opacity(0.5), radius: 15, x: 0, y: 0)
                    
                    // Score in center
                    VStack(spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(Int(total))")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.primary)
                            Text("pts")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        
                        // Performance indicator
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(total > Double((i + 1) * 30) ? Theme.success : Theme.subtleDivider)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }
            }
            
            // Round breakdown
            HStack(spacing: 16) {
                ForEach(Array(roundScores.enumerated()), id: \.offset) { index, score in
                    VStack(spacing: 6) {
                        Text("R\(index + 1)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.mutedTextColor)
                        Text("\(Int(score))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.primary.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            
            Text("Average across \(EyeFocusViewModel.rounds) rounds")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Theme.mutedTextColor)
            
            GlowButton(title: "Done", icon: "checkmark", action: {
                session.markCompleted(.eyeFocus)
                session.navigateTo(nil)
            })
        }
    }

    private var immersiveDarkOverlay: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0.35),
                Color.black.opacity(0.58)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .blendMode(.multiply)
        .overlay(
            RadialGradient(
                colors: [
                    Theme.primary.opacity(0.22),
                    Color.clear
                ],
                center: .top,
                startRadius: 10,
                endRadius: 520
            )
            .blendMode(.plusLighter)
            .opacity(0.95)
        )
    }
}

#Preview {
    NavigationStack {
        EyeFocusView(session: SessionState())
    }
}
