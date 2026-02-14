//
//  HealthIndicator.swift
//  21Reflex
//
//  Heart-based health display
//

import SwiftUI

struct HealthIndicator: View {
    let current: Int
    let max: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<max, id: \.self) { index in
                Image(systemName: index < current ? "heart.fill" : "heart")
                    .foregroundStyle(index < current ? Color.red : Color.gray.opacity(0.5))
                    .font(.title2)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HealthIndicator(current: 3, max: 3)
        HealthIndicator(current: 2, max: 3)
        HealthIndicator(current: 1, max: 3)
        HealthIndicator(current: 0, max: 3)
    }
    .padding()
}
