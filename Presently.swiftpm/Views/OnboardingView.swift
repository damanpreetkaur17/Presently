//
//  OnboardingView.swift
//  StageReady
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var page = 0
    @State private var shimmer = false

    var body: some View {
        ZStack {
            // Premium animated background
            AnimatedBackground()
            
            // Floating gradient orbs
            GeometryReader { geo in
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Theme.primary.opacity(0.15),
                                    Theme.accent.opacity(0.08),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .offset(
                            x: i == 0 ? -100 : geo.size.width - 300,
                            y: i == 0 ? 100 : geo.size.height - 500
                        )
                        .blur(radius: 40)
                        .opacity(shimmer ? 0.8 : 0.5)
                        .animation(
                            .easeInOut(duration: 3 + Double(i))
                            .repeatForever(autoreverses: true),
                            value: shimmer
                        )
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Premium header
                header
                    .padding(.top, 50)
                    .padding(.horizontal, 24)
                
                Spacer(minLength: 20)
                
                // Page content
                TabView(selection: $page) {
                    onboardingPage(
                        icon: "waveform.circle.fill",
                        accentIcon: "sparkles",
                        title: "StageReady",
                        subtitle: "Your 3-Minute Pre-Stage Ritual",
                        description: "Transform nervous energy into confident presence with four scientifically-designed micro-exercises."
                    )
                    .tag(0)
                    
                    onboardingPage(
                        icon: "brain.head.profile",
                        accentIcon: "bolt.heart.fill",
                        title: "Four Dimensions",
                        subtitle: "Voice • Clarity • Focus • Memory",
                        description: "Each exercise targets a key performance dimension, creating a complete warm-up sequence."
                    )
                    .tag(1)
                    
                    onboardingPage(
                        icon: "lock.shield.fill",
                        accentIcon: "moon.stars.fill",
                        title: "Private & Offline",
                        subtitle: "Your Personal Space",
                        description: "No accounts, no tracking, no internet required. Just you and your preparation ritual."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer(minLength: 20)
                
                // Page indicator
                pageIndicator
                    .padding(.bottom, 20)
                
                // Action button
                GlowButton(
                    title: page < 2 ? "Continue" : "Begin Your Warm-Up",
                    icon: page < 2 ? "arrow.right" : "play.fill"
                ) {
                    if page < 2 {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            page += 1
                        }
                    } else {
                        HapticManager.success()
                        hasCompletedOnboarding = true
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            shimmer = true
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            AppLogo(size: 48, showText: false)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("StageReady")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                
                Text("Pre-presentation warm-up")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }
            
            Spacer()
        }
    }

    private func onboardingPage(
        icon: String,
        accentIcon: String,
        title: String,
        subtitle: String,
        description: String
    ) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Hero visual
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(Theme.accentGlowColor.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)
                
                // Gradient ring
                Circle()
                    .strokeBorder(Theme.heroCircleGradient, lineWidth: 4)
                    .frame(width: 170, height: 170)
                    .shadow(color: Theme.primary.opacity(0.4), radius: 20, x: 0, y: 10)
                
                // Inner glow
                Circle()
                    .fill(Theme.haloGlow.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                // Icons
                VStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.primary, Theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Image(systemName: accentIcon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Theme.secondary)
                }
            }
            .padding(.bottom, 50)
            
            // Content card
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)),
            removal: .opacity
        ))
    }

    private var pageIndicator: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == page ? Theme.primary : Theme.textSecondary.opacity(0.3))
                    .frame(width: i == page ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: page)
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
