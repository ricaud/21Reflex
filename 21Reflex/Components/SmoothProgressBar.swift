//
//  SmoothProgressBar.swift
//  21Reflex
//
//  Refined progress bar with smooth animations
//

import SwiftUI

struct SmoothProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var color: Color? = nil
    var height: CGFloat = 6
    var animated: Bool = true

    @Environment(\.colorScheme) private var colorScheme
    @State private var animatedProgress: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))

                // Progress fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(barColor)
                    .frame(width: max(0, geometry.size.width * animatedProgress))
            }
        }
        .frame(height: height)
        .onAppear {
            if animated {
                withAnimation(.easeOut(duration: 0.5)) {
                    animatedProgress = progress
                }
            } else {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.easeOut(duration: 0.3)) {
                animatedProgress = newValue
            }
        }
    }

    private var barColor: Color {
        if let color = color {
            return color
        }
        // Default gradient based on progress
        if animatedProgress > 0.6 {
            return .green
        } else if animatedProgress > 0.3 {
            return .orange
        } else {
            return .red
        }
    }
}

// Timer variant with countdown display
struct TimerProgressBar: View {
    var timeRemaining: Double
    var totalTime: Double
    var height: CGFloat = 6
    var showText: Bool = false

    private var progress: Double {
        max(0, min(1, timeRemaining / totalTime))
    }

    var body: some View {
        VStack(spacing: 4) {
            SmoothProgressBar(
                progress: progress,
                color: timerColor,
                height: height
            )

            if showText {
                Text("\(Int(ceil(timeRemaining)))s")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(timerColor)
            }
        }
    }

    private var timerColor: Color {
        if progress > 0.6 {
            return .green
        } else if progress > 0.3 {
            return .orange
        } else {
            return .red
        }
    }
}

// Segmented progress for multi-step processes
struct SegmentedProgressBar: View {
    var currentStep: Int
    var totalSteps: Int
    var height: CGFloat = 4

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { index in
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(index < currentStep ? Color.accentColor : Color.gray.opacity(0.2))
                    .frame(height: height)
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        // Smooth progress examples
        VStack(spacing: 12) {
            SmoothProgressBar(progress: 0.8, height: 8)
            SmoothProgressBar(progress: 0.5, color: .blue, height: 6)
            SmoothProgressBar(progress: 0.2, color: .red, height: 6)
        }
        .padding()

        // Timer variant
        TimerProgressBar(timeRemaining: 7, totalTime: 10, showText: true)
            .padding()

        // Segmented
        SegmentedProgressBar(currentStep: 3, totalSteps: 5)
            .padding()
    }
    .padding()
}
