//
//  ThemeAnimations.swift
//  21Reflex
//
//  Animation presets and helpers for different theme styles
//

import SwiftUI

/// Provides animation presets based on AnimationStyle
struct ThemeAnimations {
    let style: AnimationStyle

    /// Animation for button presses
    var buttonPress: Animation {
        switch style {
        case .smooth:
            return .easeInOut(duration: 0.1)
        case .bouncy:
            return .spring(response: 0.3, dampingFraction: 0.6)
        case .instant:
            return .linear(duration: 0)
        case .wobbly:
            return .easeInOut(duration: 0.15)
        case .glitch:
            return .linear(duration: 0.05)
        case .flip:
            return .easeInOut(duration: 0.3)
        case .elastic:
            return .spring(response: 0.4, dampingFraction: 0.4)
        }
    }

    /// Animation for view transitions
    var transition: Animation {
        switch style {
        case .smooth:
            return .easeOut(duration: 0.3)
        case .bouncy:
            return .spring(response: 0.4, dampingFraction: 0.7)
        case .instant:
            return .linear(duration: 0)
        case .wobbly:
            return .easeInOut(duration: 0.4)
        case .glitch:
            return .linear(duration: 0.1)
        case .flip:
            return .easeInOut(duration: 0.5)
        case .elastic:
            return .spring(response: 0.5, dampingFraction: 0.5)
        }
    }

    /// Animation for card dealing/movement
    var cardMovement: Animation {
        switch style {
        case .smooth:
            return .easeOut(duration: 0.3)
        case .bouncy:
            return .spring(response: 0.4, dampingFraction: 0.6)
        case .instant:
            return .linear(duration: 0)
        case .wobbly:
            return .easeInOut(duration: 0.35)
        case .glitch:
            return .linear(duration: 0.08)
        case .flip:
            return .easeInOut(duration: 0.4)
        case .elastic:
            return .spring(response: 0.5, dampingFraction: 0.4)
        }
    }

    /// Animation for feedback (correct/wrong answers)
    var feedback: Animation {
        switch style {
        case .smooth:
            return .easeOut(duration: 0.2)
        case .bouncy:
            return .spring(response: 0.3, dampingFraction: 0.5)
        case .instant:
            return .linear(duration: 0.05)
        case .wobbly:
            return .easeInOut(duration: 0.25)
        case .glitch:
            return .linear(duration: 0.03)
        case .flip:
            return .easeInOut(duration: 0.25)
        case .elastic:
            return .spring(response: 0.35, dampingFraction: 0.35)
        }
    }

    /// Animation for score/counter changes
    var counter: Animation {
        switch style {
        case .smooth:
            return .easeOut(duration: 0.2)
        case .bouncy, .elastic:
            return .spring(response: 0.3, dampingFraction: 0.5)
        case .instant:
            return .linear(duration: 0)
        case .wobbly:
            return .easeInOut(duration: 0.2)
        case .glitch:
            return .linear(duration: 0.05)
        case .flip:
            return .easeInOut(duration: 0.2)
        }
    }

    /// Scale effect for button presses
    var buttonPressScale: CGFloat {
        switch style {
        case .smooth, .instant:
            return 0.97
        case .bouncy, .elastic:
            return 0.95
        case .wobbly:
            return 0.96
        case .glitch:
            return 1.02 // Glitch expands instead of shrinks
        case .flip:
            return 0.98
        }
    }

    /// Shake offset for wrong answers
    var shakeOffset: CGFloat {
        switch style {
        case .smooth:
            return 8
        case .bouncy, .elastic:
            return 12
        case .instant:
            return 10
        case .wobbly:
            return 10
        case .glitch:
            return 15
        case .flip:
            return 8
        }
    }
}

// MARK: - View Modifiers

/// Applies theme-appropriate animation to a view
struct ThemedAnimationModifier: ViewModifier {
    let style: AnimationStyle
    let animationType: AnimationType

    enum AnimationType {
        case buttonPress
        case transition
        case cardMovement
        case feedback
        case counter
    }

    private var animation: Animation {
        let animations = ThemeAnimations(style: style)
        switch animationType {
        case .buttonPress:
            return animations.buttonPress
        case .transition:
            return animations.transition
        case .cardMovement:
            return animations.cardMovement
        case .feedback:
            return animations.feedback
        case .counter:
            return animations.counter
        }
    }

    func body(content: Content) -> some View {
        content.animation(animation, value: UUID())
    }
}

extension View {
    func themedAnimation(_ style: AnimationStyle, type: ThemedAnimationModifier.AnimationType) -> some View {
        modifier(ThemedAnimationModifier(style: style, animationType: type))
    }
}
