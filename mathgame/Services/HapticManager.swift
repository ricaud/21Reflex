//
//  HapticManager.swift
//  mathgame
//
//  Haptic feedback management
//

import UIKit
import SwiftUI

@Observable
@MainActor
class HapticManager {
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    var isEnabled: Bool = true

    func prepare() {
        guard isEnabled else { return }
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }

    func playCorrectFeedback() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
    }

    func playWrongFeedback() {
        guard isEnabled else { return }
        impactHeavy.impactOccurred()
    }

    func playButtonTap() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
    }

    func playSelection() {
        guard isEnabled else { return }
        selection.selectionChanged()
    }

    func playAchievement() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
    }

    func playError() {
        guard isEnabled else { return }
        notification.notificationOccurred(.error)
    }

    func playWarning() {
        guard isEnabled else { return }
        notification.notificationOccurred(.warning)
    }

    func playBuffSelection() {
        guard isEnabled else { return }
        impactMedium.impactOccurred()
    }

    func playPurchase() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
    }
}
