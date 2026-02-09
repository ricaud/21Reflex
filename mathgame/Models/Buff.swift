//
//  Buff.swift
//  mathgame
//
//  Buff definitions and effects
//

import Foundation

struct Buff: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let isStackable: Bool
    let icon: String

    static let allBuffs: [Buff] = [
        // Original buffs
        Buff(id: "extra_time", name: "Extra Time", description: "+3s per question", isStackable: false, icon: "clock.fill"),
        Buff(id: "double_coins", name: "Coin Multiplier", description: "2× coins earned", isStackable: false, icon: "dollarsign.circle.fill"),
        Buff(id: "extra_health", name: "Extra Heart", description: "+1 max health", isStackable: true, icon: "heart.fill"),
        Buff(id: "freeze_time", name: "Time Freeze", description: "Timer pauses 1s after correct", isStackable: false, icon: "pause.circle.fill"),
        Buff(id: "streak_bonus", name: "Streak Master", description: "Streak bonus starts at 3", isStackable: false, icon: "flame.fill"),
        Buff(id: "slow_timer", name: "Slow Motion", description: "Timer runs 25% slower", isStackable: true, icon: "tortoise.fill"),

        // New buffs
        Buff(id: "shield", name: "Shield", description: "Block one wrong answer", isStackable: false, icon: "shield.fill"),
        Buff(id: "time_bonus", name: "Time Bank", description: "Add +5s to current question", isStackable: true, icon: "plus.circle.fill"),
        Buff(id: "lucky", name: "Lucky Guess", description: "50% chance wrong doesn't hurt", isStackable: false, icon: "dice.fill"),
        Buff(id: "coin_shower", name: "Coin Shower", description: "+5 coins immediately", isStackable: true, icon: "cloud.rain.fill"),
        Buff(id: "second_chance", name: "Second Chance", description: "One free retry per run", isStackable: false, icon: "arrow.counterclockwise.circle.fill"),
        Buff(id: "multiplier_stack", name: "Streak Multiplier", description: "Streak bonus doubled", isStackable: false, icon: "2.circle.fill"),
        Buff(id: "time_stop", name: "Time Stop", description: "Timer pauses 2s on wrong", isStackable: false, icon: "stopwatch.fill")
    ]

    static func randomBuffs(count: Int, excluding owned: [Buff]) -> [Buff] {
        let ownedIds = Set(owned.map { $0.id })
        var available = allBuffs.filter { buff in
            if ownedIds.contains(buff.id) && !buff.isStackable {
                return false
            }
            return true
        }
        available.shuffle()
        return Array(available.prefix(count))
    }

    static func getById(_ id: String) -> Buff? {
        allBuffs.first { $0.id == id }
    }
}

// Active buff with remaining uses (for stackable buffs)
struct ActiveBuff: Identifiable {
    let id = UUID()
    let buff: Buff
    var remainingUses: Int

    init(buff: Buff, uses: Int = 1) {
        self.buff = buff
        self.remainingUses = uses
    }
}
