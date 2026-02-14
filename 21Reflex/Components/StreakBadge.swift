//
//  StreakBadge.swift
//  21Reflex
//
//  Streak counter with fire icon
//

import SwiftUI

struct StreakBadge: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 4) {
            if streak >= 10 {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
            }

            Text("STREAK: \(streak)")
                .font(.headline.bold())
                .foregroundStyle(streakColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.2))
        )
    }

    private var streakColor: Color {
        if streak >= 25 {
            return .purple
        } else if streak >= 10 {
            return .orange
        } else {
            return .primary
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakBadge(streak: 0)
        StreakBadge(streak: 5)
        StreakBadge(streak: 12)
        StreakBadge(streak: 30)
    }
    .padding()
}
