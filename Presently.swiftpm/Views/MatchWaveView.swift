//
//  MatchWaveView.swift
//  StageReady
//

import SwiftUI
import AVFoundation
import Charts

struct MatchWaveView: View {
    @ObservedObject var session: SessionState
    @StateObject private var meter = AudioMetering()
    @StateObject private var viewModel = MatchWaveViewModel()
    @State private var pulse = false

    var body: some View {
        ZStack {
            AnimatedBackground()
                .overlay(floatingLight, alignment: .top)

            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: geometry.size.height * 0.08)
                        
                        VStack(spacing: 24) {
                            headerOverlay
                            if viewModel.phase == .result {
                                resultView
                                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                            } else {
                                mainMeterView
                                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                            }
                        }
                        
                        Spacer(minLength: geometry.size.height * 0.08)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Match the Wave")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.phase) { p in
            if p == .result { meter.stopRecording() }
        }
        .onAppear {
            viewModel.reset()
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { pulse = true }
        }
        .onDisappear {
            meter.stopRecording()
            // Reset navigation when leaving view
            if session.currentChallenge == .matchWave {
                session.navigateTo(nil)
            }
        }
    }

    private var headerOverlay: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "waveform")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Theme.primary)
                        Text("Match the Wave")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    Text("Keep your voice inside the glass band")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                if viewModel.phase == .recording {
                    VStack(spacing: 4) {
                        Text("\(Int(viewModel.remainingSeconds))")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.primary)
                        Text("sec")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Theme.primary.opacity(0.20), lineWidth: 1.5)
                    )
                    .shadow(color: Theme.primary.opacity(0.25), radius: 20, x: 0, y: 12)
                }
            }
        }
    }

    private var mainMeterView: some View {
        VStack(spacing: 28) {
            GlassPanel {
                ZStack {
                    BlobWaveMeterView(
                        level: meter.smoothedLevel,
                        samples: viewModel.samples,
                        isRecording: viewModel.phase == .recording
                    )
                    .frame(height: 220)

                    // Vertical glass target band with enhanced glow
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 74)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Theme.success.opacity(0.45), lineWidth: 1.5)
                        )
                        .shadow(color: Theme.success.opacity(0.30), radius: 20, x: 0, y: 12)
                        .blendMode(.plusLighter)
                        .opacity(0.95)

                    // Dynamic glow feedback
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(meterGlowColor.opacity(0.40), lineWidth: 2)
                        .blur(radius: 3)
                        .shadow(color: meterGlowColor.opacity(0.35), radius: 22, x: 0, y: 14)
                        .padding(-2)
                }
            }

            if viewModel.phase == .idle {
                VStack(spacing: 12) {
                    Text("Speak steadily to keep your voice inside the glowing band")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                    GlowButton(title: "Start (20 sec)", icon: "mic.fill", action: {
                        viewModel.startRecording()
                        meter.requestPermissionAndStart()
                    })
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView(value: 1 - viewModel.remainingSeconds / MatchWaveViewModel.duration)
                        .tint(Theme.primary)
                        .frame(height: 6)
                        .clipShape(Capsule())
                        .shadow(color: Theme.primary.opacity(0.30), radius: 12, x: 0, y: 8)
                    
                    Text("Recording...")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .onChange(of: meter.smoothedLevel) { newValue in
            viewModel.addSample(newValue)
        }
    }

    private var resultView: some View {
        VStack(spacing: 32) {
            // Animated success icon
            ZStack {
                Circle()
                    .fill(Theme.success.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)
                
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.success, Theme.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("Voice Stability Analysis")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                
                Text("Your voice control across 10 segments")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            stabilityChart
            
            GlowButton(title: "Done", icon: "checkmark", action: {
                session.markCompleted(.matchWave)
                session.navigateTo(nil)
            })
        }
    }

    private var stabilityChart: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Segment Analysis")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    // Average score indicator
                    let avgScore = viewModel.stabilityScores.reduce(0, +) / Double(max(1, viewModel.stabilityScores.count))
                    HStack(spacing: 4) {
                        Circle()
                            .fill(avgScore > 0.6 ? Theme.success : avgScore > 0.3 ? Theme.warning : Theme.error)
                            .frame(width: 8, height: 8)
                        Text(String(format: "%.0f%%", avgScore * 100))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                
                Chart(Array(viewModel.stabilityScores.enumerated()), id: \.offset) { index, score in
                    BarMark(
                        x: .value("Segment", index + 1),
                        y: .value("Stability", score)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                score > 0.6 ? Theme.success : score > 0.3 ? Theme.warning : Theme.error,
                                (score > 0.6 ? Theme.success : score > 0.3 ? Theme.warning : Theme.error).opacity(0.6)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(6)
                }
                .chartYScale(domain: 0...1)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Theme.mutedTextColor)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: [0, 0.5, 1.0]) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text("\(Int(val * 100))%")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(Theme.mutedTextColor)
                            }
                        }
                    }
                }
                .frame(height: 160)
            }
        }
    }

    private var meterGlowColor: Color {
        if meter.smoothedLevel < -25 && meter.smoothedLevel > -100 { return Theme.primary }
        if meter.smoothedLevel > -15 { return Theme.error }
        return Theme.success
    }

    private var floatingLight: some View {
        GeometryReader { geo in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            meterGlowColor.opacity(0.20),
                            Theme.accent.opacity(0.10),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 420, height: 420)
                .position(x: geo.size.width * (pulse ? 0.75 : 0.25), y: 60)
                .blur(radius: 2)
                .opacity(0.95)
                .allowsHitTesting(false)
                .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: pulse)
        }
        .ignoresSafeArea()
        .blendMode(.plusLighter)
    }
}

private struct BlobWaveMeterView: View {
    let level: Float
    let samples: [Float]
    let isRecording: Bool

    private let targetLow: Float = -25
    private let targetHigh: Float = -15
    @State private var wobble: CGFloat = 0

    private var normalizedLevel: CGFloat {
        let n = (level + 60) / 60
        return CGFloat(min(1, max(0, n)))
    }

    private var meterColor: Color {
        if level < targetLow && level > -100 { return Theme.primary }
        if level > targetHigh { return Theme.error }
        return Theme.success
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let w = size.width
            let h = size.height

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.10),
                                Color.black.opacity(0.02),
                                Color.white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Soft morphing “blob wave”
                Canvas { context, _ in
                    let s = Array(samples.suffix(40))
                    let count = max(12, s.count)
                    let step = w / CGFloat(count - 1)

                    var points: [CGPoint] = []
                    points.reserveCapacity(count)

                    for i in 0..<count {
                        let idx = min(s.count - 1, max(0, i))
                        let amp = s.isEmpty ? 0.2 : CGFloat(s[idx])
                        let y = h * (0.5 - 0.35 * amp) + 12 * sin(wobble + CGFloat(i) * 0.35)
                        points.append(CGPoint(x: CGFloat(i) * step, y: y))
                    }

                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: h))
                    // Smooth curve through points
                    if let first = points.first {
                        path.addLine(to: first)
                    }
                    for i in 1..<points.count {
                        let prev = points[i - 1]
                        let cur = points[i]
                        let mid = CGPoint(x: (prev.x + cur.x) / 2, y: (prev.y + cur.y) / 2)
                        path.addQuadCurve(to: mid, control: prev)
                    }
                    if let last = points.last {
                        path.addQuadCurve(to: last, control: last)
                        path.addLine(to: CGPoint(x: w, y: h))
                        path.closeSubpath()
                    }

                    let fill = GraphicsContext.Shading.linearGradient(
                        Gradient(colors: [
                            meterColor.opacity(0.35),
                            meterColor.opacity(0.18),
                            Color.clear
                        ]),
                        startPoint: CGPoint(x: w * 0.5, y: 0),
                        endPoint: CGPoint(x: w * 0.5, y: h)
                    )
                    context.fill(path, with: fill)

                    // Glow stroke along the crest
                    var crest = Path()
                    if let first = points.first {
                        crest.move(to: first)
                    }
                    for i in 1..<points.count {
                        crest.addLine(to: points[i])
                    }
                    context.stroke(
                        crest,
                        with: .color(meterColor.opacity(0.55)),
                        style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round)
                    )
                }
                .shadow(color: meterColor.opacity(0.25), radius: 22, x: 0, y: 14)
                .opacity(isRecording ? 1 : 0.65)

                // Center marker
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.textPrimary.opacity(0.12))
                    .frame(width: 2, height: h * 0.72)
                    .opacity(0.8)

                // Live level dot
                Circle()
                    .fill(meterColor)
                    .frame(width: 10, height: 10)
                    .shadow(color: meterColor.opacity(0.6), radius: 10, x: 0, y: 0)
                    .position(x: w * 0.5, y: h * (0.74 - 0.60 * normalizedLevel))
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Theme.textPrimary.opacity(0.10), lineWidth: 1)
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: true)) {
                wobble = .pi * 2
            }
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
        MatchWaveView(session: SessionState())
    }
}
