//
//  MemorySparkView.swift
//  StageReady
//

import SwiftUI

struct MemorySparkView: View {
    @ObservedObject var session: SessionState
    @StateObject private var viewModel = MemorySparkViewModel()
    @State private var puzzleAnswer: String = ""
    @FocusState private var focusRecall: Bool
    @State private var reveal = false

    var body: some View {
        ZStack {
            AnimatedBackground()
                .overlay(floatingLight, alignment: .top)
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: geometry.size.height * 0.15)
                        
                        VStack(spacing: 32) {
                            switch viewModel.phase {
                            case .showSentence:
                                sentenceView
                            case .hide:
                                VStack(spacing: 20) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 64, weight: .light))
                                        .foregroundStyle(Theme.primary.opacity(0.6))
                                    
                                    Text("Remember the sentence...")
                                        .font(.system(size: 20, weight: .medium, design: .rounded))
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 80)
                            case .puzzle:
                                puzzleView
                            case .recall:
                                recallView
                            case .result:
                                if let res = viewModel.result { resultView(res) }
                            }
                        }
                        
                        Spacer(minLength: geometry.size.height * 0.15)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Memory Spark")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadSentence() }
        .onChange(of: viewModel.phase) { newPhase in
            if newPhase == .result {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) { reveal = true }
            }
        }
        .onDisappear {
            // Reset navigation when leaving view
            if session.currentChallenge == .memorySpark {
                session.navigateTo(nil)
            }
        }
    }

    private var sentenceView: some View {
        VStack(spacing: 28) {
            Image(systemName: "text.quote")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Theme.primary.opacity(0.7))
            
            Text("Memorize this sentence")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
            
            GlassPanel {
                VStack(spacing: 16) {
                    Text(viewModel.sentence)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.vertical, 8)
                    
                    Divider()
                        .background(Theme.subtleDivider)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .medium))
                        Text("4 seconds")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(Theme.mutedTextColor)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + MemorySparkViewModel.showDuration) {
                viewModel.phase = .hide

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewModel.startPuzzle()
                }
            }
        }
    }

    private var puzzleView: some View {
        VStack(spacing: 32) {
            Image(systemName: "function")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Theme.accent.opacity(0.7))
            
            VStack(spacing: 12) {
                Text("Quick mental challenge")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                
                Text("Solve this while holding the sentence in memory")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(Theme.mutedTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            GlassPanel {
                VStack(spacing: 20) {
                    Text("Calculate")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.mutedTextColor)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    HStack(spacing: 16) {
                        Text(viewModel.puzzleQuestion)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text("=")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(Theme.textSecondary)
                        
                        TextField("?", text: $puzzleAnswer)
                            .keyboardType(.numberPad)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .frame(width: 90)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Theme.primary.opacity(0.30), lineWidth: 2)
                            )
                    }
                }
            }
            
            GlowButton(title: "Continue", icon: "arrow.right", action: {
                if let n = Int(puzzleAnswer) {
                    viewModel.checkPuzzle(n)
                }
                puzzleAnswer = ""
                viewModel.phase = .recall
                focusRecall = true
            })
        }
    }

    private var recallView: some View {
        VStack(spacing: 28) {
            Image(systemName: "pencil.and.list.clipboard")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Theme.secondary.opacity(0.7))
            
            VStack(spacing: 12) {
                Text("Type the sentence you remember")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                
                Text("Try to recall as many words as possible")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(Theme.mutedTextColor)
            }
            
            GlassPanel {
                TextEditor(text: $viewModel.typedText)
                    .font(.system(size: 18, design: .rounded))
                    .frame(minHeight: 160)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($focusRecall)
            }
            
            GlowButton(title: "Submit", icon: "checkmark", action: {
                viewModel.computeResult()
            })
        }
    }

    private func resultView(_ res: MemorySparkViewModel.Result) -> some View {
        VStack(spacing: 36) {
            // Animated star rating with glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(scoreColor(res.score).opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: res.score == .strongRecall ? "star.fill" : res.score == .smallGaps ? "star.leadinghalf.filled" : "star")
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [scoreColor(res.score), scoreColor(res.score).opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: scoreColor(res.score).opacity(0.5), radius: 20, x: 0, y: 10)
            }
            
            VStack(spacing: 16) {
                Text(res.score.rawValue)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor(res.score))
                    .opacity(reveal ? 1 : 0)
                    .scaleEffect(reveal ? 1 : 0.94)
                
                // Animated circular percentage gauge
                ZStack {
                    // Background track
                    Circle()
                        .stroke(Theme.subtleDivider.opacity(0.3), lineWidth: 14)
                        .frame(width: 160, height: 160)
                    
                    // Animated progress
                    Circle()
                        .trim(from: 0, to: Double(res.correctWords) / Double(res.totalWords))
                        .stroke(
                            AngularGradient(
                                colors: [scoreColor(res.score), scoreColor(res.score).opacity(0.6)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.9, dampingFraction: 0.7).delay(0.2), value: reveal)
                        .shadow(color: scoreColor(res.score).opacity(0.4), radius: 10, x: 0, y: 0)
                    
                    // Score in center
                    VStack(spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(res.correctWords)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.primary)
                            Text("/")
                                .font(.system(size: 24, weight: .light, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                            Text("\(res.totalWords)")
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .opacity(reveal ? 1 : 0)
                        
                        Text("words")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.mutedTextColor)
                            .textCase(.uppercase)
                            .tracking(1)
                            .opacity(reveal ? 1 : 0)
                    }
                }
                
                // Percentage indicator
                Text(String(format: "%.0f%% accuracy", Double(res.correctWords) / Double(res.totalWords) * 100))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .opacity(reveal ? 1 : 0)
            }
            
            comparisonView(res)
            
            GlowButton(title: "Done", icon: "checkmark", action: {
                session.markCompleted(.memorySpark)
                session.navigateTo(nil)
            })
        }
    }

    private func scoreColor(_ s: MemorySparkViewModel.Score) -> Color {
        switch s {
        case .strongRecall: return Theme.success
        case .smallGaps: return Theme.warning
        case .reviewAgain: return Theme.error
        }
    }

    private func comparisonView(_ res: MemorySparkViewModel.Result) -> some View {
        let words = viewModel.sentence.split(separator: " ").map(String.init)
        return GlassPanel {
            VStack(alignment: .leading, spacing: 10) {
                Text("Original sentence:")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                
                FlowLayout(spacing: 6) {
                    ForEach(Array(words.enumerated()), id: \.offset) { i, w in
                        Text(w)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(res.wrongWordIndices.contains(i) ? Theme.error : Theme.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                res.wrongWordIndices.contains(i)
                                ? Theme.error.opacity(reveal ? 0.20 : 0.0)
                                : Theme.primary.opacity(0.12)
                            )
                            .clipShape(Capsule())
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(i) * 0.05), value: reveal)
                    }
                }
            }
        }
    }

    private var floatingLight: some View {
        GeometryReader { geo in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Theme.primary.opacity(0.16),
                            Theme.accent.opacity(0.10),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 420, height: 420)
                .position(x: geo.size.width * 0.72, y: 60)
                .blur(radius: 2)
                .opacity(0.95)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
        .blendMode(.plusLighter)
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

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (i, p) in result.positions.enumerated() {
            subviews[i].place(at: CGPoint(x: bounds.minX + p.x, y: bounds.minY + p.y), proposal: .unspecified)
        }
    }
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? 300
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var positions: [CGPoint] = []
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

#Preview {
    NavigationStack {
        MemorySparkView(session: SessionState())
    }
}
