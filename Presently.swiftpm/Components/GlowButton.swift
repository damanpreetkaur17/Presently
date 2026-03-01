//
//  GlowButton.swift
//  StageReady
//

import SwiftUI

struct GlowButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var style: Style = .primary
    @State private var isPressed = false

    enum Style {
        case primary
        case secondary
        case success
    }

    private var gradient: LinearGradient {
        switch style {
        case .primary: return Theme.buttonGradient
        case .secondary: 
            return LinearGradient(
                colors: [Theme.textSecondary.opacity(0.65), Theme.textSecondary.opacity(0.45)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .success: return Theme.successGradient
        }
    }
    
    private var glowColor: Color {
        switch style {
        case .primary: return Theme.primary
        case .secondary: return Theme.textSecondary
        case .success: return Theme.success
        }
    }

    var body: some View {
        Button(action: {
            HapticManager.light()
            action()
        }) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(gradient)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.22),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .blendMode(.overlay)
                        )
                    
                    // Glow effect
                    if style != .secondary {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(glowColor.opacity(0.35))
                            .blur(radius: 20)
                            .scaleEffect(1.05)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: glowColor.opacity(0.40), radius: 20, x: 0, y: 12)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
}

private struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { pressed in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = pressed
                }
            }
    }
}

#Preview {
    VStack(spacing: 16) {
        GlowButton(title: "Start", icon: "play.fill", action: {})
        GlowButton(title: "Skip", icon: nil, action: {}, style: .secondary)
    }
    .padding()
}
