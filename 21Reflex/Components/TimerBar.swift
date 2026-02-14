//
//  TimerBar.swift
//  21Reflex
//
//  Animated timer progress bar
//

import SwiftUI

struct TimerBar: View {
    let progress: Double // 0.0 to 1.0
    let height: CGFloat = 24

    var body: some View {
        GeometryReader { geometry in
            let inset: CGFloat = 3 // Border line width
            let availableWidth = geometry.size.width - (inset * 2)
            let fillWidth = max(0, min(availableWidth, availableWidth * progress))

            ZStack(alignment: .leading) {
                // Background (inset to account for border)
                RoundedRectangle(cornerRadius: (height - inset * 2) / 2)
                    .fill(Color.gray.opacity(0.3))
                    .padding(inset)

                // Progress fill - stays inside the border
                RoundedRectangle(cornerRadius: (height - inset * 2) / 2)
                    .fill(barColor)
                    .frame(width: fillWidth, height: height - inset * 2)
                    .padding(.leading, inset)
                    .animation(.linear(duration: 0.1), value: progress)
            }
        }
        .frame(height: height)
        .overlay(
            RoundedRectangle(cornerRadius: height / 2)
                .stroke(Color.black, lineWidth: 3)
        )
    }

    private var barColor: Color {
        if progress < 0.3 {
            return Color(red: 0.9, green: 0.35, blue: 0.35) // Red
        } else if progress < 0.6 {
            return Color(red: 0.95, green: 0.7, blue: 0.2) // Yellow
        } else {
            return Color(red: 0.4, green: 0.85, blue: 0.4) // Green
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TimerBar(progress: 0.9)
        TimerBar(progress: 0.5)
        TimerBar(progress: 0.2)
    }
    .padding()
}
