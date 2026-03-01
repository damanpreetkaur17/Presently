//
//  ContentView.swift
//  StageReady
//

import SwiftUI
import Combine

struct ContentView: View {
    @Binding var hasCompletedOnboarding: Bool
    @StateObject private var session = SessionState()
    @State private var showResetAlert = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                NavigationStack {
                    HomeView(session: session)
                        .background(
                            NavigationLink(
                                tag: ChallengeId.matchWave,
                                selection: $session.currentChallenge
                            ) {
                                MatchWaveView(session: session)
                            } label: {
                                EmptyView()
                            }
                        )
                        .background(
                            NavigationLink(
                                tag: ChallengeId.claritySpeed,
                                selection: $session.currentChallenge
                            ) {
                                ClaritySpeedView(session: session)
                            } label: {
                                EmptyView()
                            }
                        )
                        .background(
                            NavigationLink(
                                tag: ChallengeId.eyeFocus,
                                selection: $session.currentChallenge
                            ) {
                                EyeFocusView(session: session)
                            } label: {
                                EmptyView()
                            }
                        )
                        .background(
                            NavigationLink(
                                tag: ChallengeId.memorySpark,
                                selection: $session.currentChallenge
                            ) {
                                MemorySparkView(session: session)
                            } label: {
                                EmptyView()
                            }
                        )
                }
                // Debug: Shake device or triple-tap with 3 fingers to reset onboarding
                .onShake {
                    showResetAlert = true
                }
                .alert("Reset Onboarding?", isPresented: $showResetAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Reset", role: .destructive) {
                        hasCompletedOnboarding = false
                    }
                } message: {
                    Text("This will show the onboarding screen again on next launch.")
                }
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if session.isSessionActive { session.tick() }
        }
    }
}

#Preview {
    ContentView(hasCompletedOnboarding: .constant(true))
}

// MARK: - Shake Gesture Extension for Debug
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeGestureModifier(action: action))
    }
}

struct ShakeGestureModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

