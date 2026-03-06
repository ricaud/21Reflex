//
//  RoughRectangle.swift
//  21Reflex
//
//  Hand-drawn rectangle shape with wobbly edges
//

import SwiftUI

/// A rectangle with hand-drawn, wobbly edges for sketchbook themes
struct RoughRectangle: Shape {
    var cornerRadius: CGFloat
    var roughness: CGFloat = 2.0
    var seed: Int = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Use seed for deterministic randomness
        var rng = SeededRandomNumberGenerator(seed: seed)

        let w = rect.width
        let h = rect.height
        let r = min(cornerRadius, min(w, h) / 2)

        // Generate points around the perimeter with roughness
        var points: [CGPoint] = []

        // Top edge (left to right)
        let topPoints = interpolatePoints(
            from: CGPoint(x: r, y: 0),
            to: CGPoint(x: w - r, y: 0),
            count: max(3, Int(w / 20)),
            roughness: roughness,
            using: &rng
        )
        points.append(contentsOf: topPoints)

        // Top-right corner
        points.append(contentsOf: roughCorner(
            center: CGPoint(x: w - r, y: r),
            radius: r,
            startAngle: -.pi / 2,
            endAngle: 0,
            roughness: roughness,
            using: &rng
        ))

        // Right edge
        let rightPoints = interpolatePoints(
            from: CGPoint(x: w, y: r),
            to: CGPoint(x: w, y: h - r),
            count: max(3, Int(h / 20)),
            roughness: roughness,
            using: &rng
        )
        points.append(contentsOf: rightPoints)

        // Bottom-right corner
        points.append(contentsOf: roughCorner(
            center: CGPoint(x: w - r, y: h - r),
            radius: r,
            startAngle: 0,
            endAngle: .pi / 2,
            roughness: roughness,
            using: &rng
        ))

        // Bottom edge
        let bottomPoints = interpolatePoints(
            from: CGPoint(x: w - r, y: h),
            to: CGPoint(x: r, y: h),
            count: max(3, Int(w / 20)),
            roughness: roughness,
            using: &rng
        )
        points.append(contentsOf: bottomPoints)

        // Bottom-left corner
        points.append(contentsOf: roughCorner(
            center: CGPoint(x: r, y: h - r),
            radius: r,
            startAngle: .pi / 2,
            endAngle: .pi,
            roughness: roughness,
            using: &rng
        ))

        // Left edge
        let leftPoints = interpolatePoints(
            from: CGPoint(x: 0, y: h - r),
            to: CGPoint(x: 0, y: r),
            count: max(3, Int(h / 20)),
            roughness: roughness,
            using: &rng
        )
        points.append(contentsOf: leftPoints)

        // Top-left corner
        points.append(contentsOf: roughCorner(
            center: CGPoint(x: r, y: r),
            radius: r,
            startAngle: .pi,
            endAngle: -.pi / 2,
            roughness: roughness,
            using: &rng
        ))

        // Build path
        guard let first = points.first else { return path }

        path.move(to: first)

        for i in 1..<points.count {
            let current = points[i]
            let prev = points[i - 1]
            let mid = CGPoint(
                x: (prev.x + current.x) / 2,
                y: (prev.y + current.y) / 2
            )

            // Use quadratic curves for smoother rough edges
            path.addQuadCurve(to: mid, control: prev)
        }

        // Close the path
        path.addQuadCurve(to: first, control: points.last!)
        path.closeSubpath()

        return path
    }

    // MARK: - Helper Functions

    private func interpolatePoints(
        from: CGPoint,
        to: CGPoint,
        count: Int,
        roughness: CGFloat,
        using rng: inout SeededRandomNumberGenerator
    ) -> [CGPoint] {
        var points: [CGPoint] = [from]

        for i in 1..<count {
            let t = CGFloat(i) / CGFloat(count)
            var x = from.x + (to.x - from.x) * t
            var y = from.y + (to.y - from.y) * t

            // Add roughness perpendicular to edge
            let dx = to.x - from.x
            let dy = to.y - from.y
            let len = sqrt(dx * dx + dy * dy)

            if len > 0 {
                let perpX = -dy / len
                let perpY = dx / len
                let offset = CGFloat.random(in: -roughness...roughness, using: &rng)
                x += perpX * offset
                y += perpY * offset
            }

            points.append(CGPoint(x: x, y: y))
        }

        points.append(to)
        return points
    }

    private func roughCorner(
        center: CGPoint,
        radius: CGFloat,
        startAngle: Double,
        endAngle: Double,
        roughness: CGFloat,
        using rng: inout SeededRandomNumberGenerator
    ) -> [CGPoint] {
        let segments = max(2, Int(radius / 5))
        var points: [CGPoint] = []

        for i in 0...segments {
            let t = Double(i) / Double(segments)
            let angle = startAngle + (endAngle - startAngle) * t

            var x = center.x + radius * cos(angle)
            var y = center.y + radius * sin(angle)

            // Add roughness
            x += CGFloat.random(in: -roughness...roughness, using: &rng)
            y += CGFloat.random(in: -roughness...roughness, using: &rng)

            points.append(CGPoint(x: x, y: y))
        }

        return points
    }
}

// MARK: - Seeded Random Number Generator

/// Deterministic random number generator for consistent rough shapes
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) {
        state = UInt64(bitPattern: Int64(seed))
        // Warm up
        _ = next()
        _ = next()
    }

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}

extension CGFloat {
    static func random(in range: ClosedRange<CGFloat>, using rng: inout SeededRandomNumberGenerator) -> CGFloat {
        let max = UInt64.max
        let randomValue = Double(rng.next()) / Double(max)
        let span = Double(range.upperBound - range.lowerBound)
        return CGFloat(Double(range.lowerBound) + randomValue * span)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        RoughRectangle(cornerRadius: 8, roughness: 2)
            .stroke(Color.black, lineWidth: 2)
            .frame(width: 200, height: 60)

        RoughRectangle(cornerRadius: 12, roughness: 3)
            .fill(Color.blue.opacity(0.3))
            .overlay(
                RoughRectangle(cornerRadius: 12, roughness: 3)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .frame(width: 150, height: 100)

        RoughRectangle(cornerRadius: 4, roughness: 1.5)
            .fill(Color.white)
            .shadow(color: .gray.opacity(0.3), radius: 2, x: 2, y: 2)
            .overlay(
                RoughRectangle(cornerRadius: 4, roughness: 1.5)
                    .stroke(Color.black, lineWidth: 2)
            )
            .frame(width: 120, height: 80)
    }
    .padding()
}
