//
//  HomeView.swift
//  StageReady
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var session: SessionState
    @AppStorage("preferredColorScheme") private var preferredColorSchemeRaw = 0
    @State private var breathe = false
    @State private var showSummary = false
    @State private var summaryBars: [CGFloat] = [0, 0, 0, 0]

    var body: some View {
        ZStack {
            AnimatedBackground()
                .overlay(floatingLight, alignment: .top)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {
                    heroHeader

                    if showSummary {
                        finalSummary
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    } else {
                        if session.isSessionActive {
                            progressSection
                        } else {
                            startWarmupRing
                                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        }
                        challengesList
                            .transition(.opacity)
                    }
                }
                .padding(20)
                .padding(.bottom, 44)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                breathe = true
            }
        }
        .onChange(of: session.completedChallenges) { _ in
            let completedAll = session.completedChallenges.count == ChallengeId.allCases.count
            if completedAll, !showSummary {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.9)) {
                    showSummary = true
                }
                animateSummaryBars()
            }
        }
    }

    private var heroHeader: some View {
        VStack(spacing: 18) {
            HStack {
                HStack(spacing: 12) {
                    CompactAppLogo(size: 36)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Good luck, you've got this.")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                        Text("A 3‑minute reset before you step on stage.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                Spacer()
                themeToggle
            }

            GlassPanel {
                HStack(spacing: 18) {
                    ZStack {
                        // Animated glow ring
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Theme.accentGlowColor.opacity(0.40),
                                        Theme.haloGlow.opacity(0.15),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 76, height: 76)
                            .blur(radius: 1)
                        
                        Circle()
                            .strokeBorder(
                                Theme.heroCircleGradient,
                                lineWidth: 4
                            )
                            .frame(width: 68, height: 68)
                            .shadow(color: Theme.primary.opacity(0.50), radius: 16, x: 0, y: 10)
                        VStack(spacing: 1) {
                            Text("3")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)
                            Text("min")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Today's focus session")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Four quick exercises tuned for the 3–4 minutes before a talk.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                        HStack(spacing: 8) {
                            chip(icon: "mic.fill", text: "Voice")
                            chip(icon: "bolt.fill", text: "Clarity")
                            chip(icon: "eye", text: "Focus")
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    private var themeToggle: some View {
        Menu {
            Button("System") { preferredColorSchemeRaw = 0 }
            Button("Light") { preferredColorSchemeRaw = 1 }
            Button("Dark") { preferredColorSchemeRaw = 2 }
        } label: {
            Image(systemName: preferredColorSchemeRaw == 2 ? "moon.fill" : preferredColorSchemeRaw == 1 ? "sun.max.fill" : "circle.lefthalf.filled")
                .font(.system(size: 22))
                .foregroundStyle(Theme.primary)
                .frame(width: 40, height: 40)
        }
    }

    private var progressSection: some View {
        GlassPanel {
            VStack(spacing: 16) {
                HStack {
                    Text("Session progress")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(formatTime(session.elapsedSeconds))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                ZStack(alignment: .center) {
                    ProgressRing(
                        progress: session.elapsedSeconds,
                        totalSeconds: SessionState.totalSessionSeconds,
                        lineWidth: 12
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: Theme.primary.opacity(0.35), radius: 14, x: 0, y: 10)
                    Text("\(Int(session.elapsedSeconds))s")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var challengesList: some View {
        VStack(spacing: 12) {
            ForEach(ChallengeId.allCases) { id in
                ChallengeRow(
                    id: id,
                    isCompleted: session.completedChallenges.contains(id),
                    action: { session.navigateTo(id) }
                )
            }
        }
    }

    private func formatTime(_ sec: Double) -> String {
        let m = Int(sec) / 60
        let s = Int(sec) % 60
        return String(format: "%d:%02d", m, s)
    }

    private func chip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 11, weight: .medium, design: .rounded))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Theme.primary.opacity(0.18), lineWidth: 1)
        )
        .foregroundStyle(Theme.textPrimary)
        .clipShape(Capsule())
    }

    // MARK: - Home Start Ring

    private var startWarmupRing: some View {
        VStack(spacing: 18) {
            ZStack {
                // Pulsing halo glow
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
                            endRadius: 180
                        )
                    )
                    .frame(width: 320, height: 320)
                    .blur(radius: 2)
                    .opacity(breathe ? 1 : 0.70)
                    .scaleEffect(breathe ? 1.05 : 0.96)

                // Hero ring with gradient
                Circle()
                    .stroke(
                        Theme.heroCircleGradient,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .shadow(color: Theme.primary.opacity(0.55), radius: 22, x: 0, y: 16)
                    .opacity(breathe ? 1 : 0.85)

                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 190, height: 190)
                    .overlay(
                        Circle()
                            .stroke(Theme.textPrimary.opacity(0.10), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.10), radius: 22, x: 0, y: 18)

                VStack(spacing: 10) {
                    Text("Start")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text("3‑Minute Warm‑Up")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                    Text("Tap to begin")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Theme.textSecondary.opacity(0.9))
                }
                .multilineTextAlignment(.center)
            }
            .contentShape(Circle())
            .onTapGesture {
                HapticManager.medium()
                session.startSession() // keep original logic call
            }
            .padding(.top, 6)

            Text("You can run challenges in any order.")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.6, dampingFraction: 0.85), value: breathe)
    }

    // MARK: - Final Summary (in-place overlay, no navigation changes)

    private var finalSummary: some View {
        VStack(spacing: 24) {
            // Glowing hero text with animated gradient
            VStack(spacing: 16) {
                ZStack {
                    // Glow effect behind text
                    Text("You Are StageReady.")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.primary)
                        .blur(radius: 20)
                        .opacity(0.6)
                    
                    Text("You Are StageReady.")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.primary, Theme.accent, Theme.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .multilineTextAlignment(.center)
                .shadow(color: Theme.primary.opacity(0.5), radius: 20, x: 0, y: 10)
                
                Text("Four quick wins. Now breathe—then speak.")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Enhanced visual analytics chart
            GlassPanel {
                VStack(spacing: 20) {
                    HStack {
                        Text("Performance Overview")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 12))
                            Text("4/4")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(Theme.success)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.success.opacity(0.15), in: Capsule())
                    }
                    
                    // Animated vertical bar chart
                    HStack(alignment: .bottom, spacing: 16) {
                        ForEach(Array(ChallengeId.allCases.enumerated()), id: \.offset) { index, challenge in
                            VStack(spacing: 8) {
                                // Animated bar with gradient
                                ZStack(alignment: .bottom) {
                                    // Background track
                                    Capsule()
                                        .fill(Theme.subtleDivider.opacity(0.3))
                                        .frame(width: 32, height: 120)
                                    
                                    // Animated fill
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Theme.primary.opacity(0.9),
                                                    Theme.accent.opacity(0.7)
                                                ],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .frame(width: 32, height: 120 * summaryBars[index])
                                        .shadow(color: Theme.primary.opacity(0.4), radius: 8, x: 0, y: 4)
                                        .overlay(
                                            // Shimmer effect
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.white.opacity(0.3),
                                                            Color.clear,
                                                            Color.white.opacity(0.2)
                                                        ],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                                .frame(width: 32, height: 120 * summaryBars[index])
                                        )
                                }
                                .animation(
                                    .spring(response: 0.7, dampingFraction: 0.75)
                                    .delay(Double(index) * 0.1),
                                    value: summaryBars[index]
                                )
                                
                                // Challenge icon
                                Image(systemName: challenge.icon)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.textSecondary)
                                    .frame(width: 32)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }

            GlowButton(title: "Finish Session", icon: "sparkles", action: {
                session.endSession()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                    showSummary = false
                }
            }, style: .success)
            .shadow(color: Theme.success.opacity(0.4), radius: 20, x: 0, y: 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 6)
    }

    private var animatedCapsuleBars: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(0..<4, id: \.self) { i in
                Capsule()
                    .fill(Theme.highlightGradient)
                    .frame(width: 26, height: 18 + 84 * summaryBars[i])
                    .shadow(color: Theme.primary.opacity(0.45), radius: 12, x: 0, y: 10)
                    .animation(.spring(response: 0.7, dampingFraction: 0.85).delay(0.08 * Double(i)), value: summaryBars[i])
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120, alignment: .bottom)
    }

    private func animateSummaryBars() {
        let target: [CGFloat] = [0.78, 0.64, 0.86, 0.72]
        summaryBars = [0, 0, 0, 0]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.86)) {
                summaryBars = target
            }
        }
    }
    // MARK: - Background lighting

    private var floatingLight: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let y: CGFloat = 80
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Theme.accent.opacity(0.18),
                            Theme.primary.opacity(0.10),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .position(x: w * (breathe ? 0.75 : 0.25), y: y)
                .blur(radius: 2)
                .opacity(0.9)
                .allowsHitTesting(false)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: breathe)
        }
        .ignoresSafeArea()
        .blendMode(.plusLighter)
    }
}

struct ChallengeRow: View {
    let id: ChallengeId
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.primary.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : id.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(isCompleted ? Theme.success : Theme.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(id.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text(id.subtitle)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Theme.textPrimary.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: Theme.primary.opacity(0.12), radius: 18, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }
}

private struct GlassPanel<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.26),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.10), radius: 24, x: 0, y: 16)
    }
}

#Preview {
    NavigationStack {
        HomeView(session: SessionState())
    }
}
