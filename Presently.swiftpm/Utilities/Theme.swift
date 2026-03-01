//
//  Theme.swift
//  StageReady
//
//  Uses explicit colors so everything renders even if
//  color assets are misconfigured.
//

import SwiftUI

struct Theme {
    // MARK: - Core Brand Colors (Cinematic Dark Theme)
    
    // Soft cyan-blue glow for primary actions
    static let primary = Color(red: 0.40, green: 0.70, blue: 0.95)
    
    // Muted teal for secondary elements
    static let secondary = Color(red: 0.45, green: 0.75, blue: 0.80)
    
    // Warm subtle gold accent
    static let accent = Color(red: 0.95, green: 0.80, blue: 0.50)
    
    // MARK: - Backgrounds
    
    // Very deep blue-black base
    static let backgroundGradientStart = Color(red: 0.08, green: 0.10, blue: 0.15)
    static let backgroundGradientEnd = Color(red: 0.12, green: 0.14, blue: 0.20)
    
    // Glass-like card background with subtle transparency
    static let cardBackground = Color(red: 0.14, green: 0.16, blue: 0.22).opacity(0.85)
    
    // Deeper glass card for layered depth
    static let glassCardBackground = Color(red: 0.10, green: 0.12, blue: 0.18).opacity(0.75)
    
    // MARK: - Text Colors
    
    // Soft off-white for primary text
    static let textPrimary = Color(red: 0.95, green: 0.96, blue: 0.98)
    
    // Cool gray for secondary text
    static let textSecondary = Color(red: 0.60, green: 0.64, blue: 0.70)
    
    // Muted text for tertiary content
    static let mutedTextColor = Color(red: 0.45, green: 0.48, blue: 0.54)
    
    // MARK: - Status Colors
    
    // Soft green glow (not neon)
    static let success = Color(red: 0.40, green: 0.80, blue: 0.60)
    
    // Warm amber
    static let warning = Color(red: 0.95, green: 0.75, blue: 0.35)
    
    // Soft coral-red (not bright red)
    static let error = Color(red: 0.90, green: 0.45, blue: 0.45)
    
    // MARK: - Glow & Accent Effects
    
    // Soft cyan-blue halo glow
    static let glow = Color(red: 0.40, green: 0.70, blue: 0.95).opacity(0.4)
    
    // Accent glow for highlights
    static let accentGlowColor = Color(red: 0.50, green: 0.75, blue: 0.95).opacity(0.6)
    
    // Halo glow for hero elements
    static let haloGlow = Color(red: 0.45, green: 0.72, blue: 0.92).opacity(0.3)
    
    // MARK: - Dividers & Shadows
    
    // Subtle divider line
    static let subtleDivider = Color(red: 0.20, green: 0.22, blue: 0.28).opacity(0.5)
    
    // Soft shadow color for depth
    static let softShadow = Color(red: 0.05, green: 0.06, blue: 0.10).opacity(0.6)
    
    // MARK: - Gradient Presets
    
    // Main background gradient (deep navy to charcoal)
    static let mainBackgroundGradient = LinearGradient(
        colors: [backgroundGradientStart, backgroundGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Hero circle gradient (cyan-blue to teal)
    static let heroCircleGradient = LinearGradient(
        colors: [
            Color(red: 0.35, green: 0.65, blue: 0.92),
            Color(red: 0.40, green: 0.72, blue: 0.78)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Highlight gradient for buttons and interactive elements
    static let highlightGradient = LinearGradient(
        colors: [
            Color(red: 0.45, green: 0.72, blue: 0.95),
            Color(red: 0.38, green: 0.68, blue: 0.85)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Ring gradient for progress indicators
    static let ringGradient = LinearGradient(
        colors: [
            Color(red: 0.40, green: 0.70, blue: 0.95),
            Color(red: 0.50, green: 0.78, blue: 0.82),
            Color(red: 0.95, green: 0.80, blue: 0.50).opacity(0.8)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Button gradient (soft glow effect)
    static let buttonGradient = LinearGradient(
        colors: [
            Color(red: 0.42, green: 0.72, blue: 0.96),
            Color(red: 0.38, green: 0.65, blue: 0.88)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Success gradient
    static let successGradient = LinearGradient(
        colors: [
            Color(red: 0.35, green: 0.78, blue: 0.58),
            Color(red: 0.42, green: 0.82, blue: 0.62)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

