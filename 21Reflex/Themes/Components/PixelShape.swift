//
//  PixelShape.swift
//  21Reflex
//
//  Pixel-perfect shapes for retro 8-bit themes
//

import SwiftUI

/// A rectangle that snaps to a pixel grid for crisp 8-bit aesthetics
struct PixelRectangle: Shape {
    var pixelSize: CGFloat = 4

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Snap to pixel grid
        let snappedX = (rect.minX / pixelSize).rounded() * pixelSize
        let snappedY = (rect.minY / pixelSize).rounded() * pixelSize
        let snappedWidth = (rect.width / pixelSize).rounded() * pixelSize
        let snappedHeight = (rect.height / pixelSize).rounded() * pixelSize

        let snappedRect = CGRect(
            x: snappedX,
            y: snappedY,
            width: snappedWidth,
            height: snappedHeight
        )

        path.addRect(snappedRect)
        return path
    }
}

/// A pixelated border shape with optional inset
struct PixelBorder: View {
    var width: CGFloat
    var height: CGFloat
    var borderWidth: CGFloat = 4
    var pixelSize: CGFloat = 4
    var color: Color = .black

    var body: some View {
        ZStack {
            // Outer rectangle
            PixelRectangle(pixelSize: pixelSize)
                .stroke(color, lineWidth: borderWidth)
                .frame(width: width, height: height)

            // Inner fill area (inset by border)
            PixelRectangle(pixelSize: pixelSize)
                .fill(Color.clear)
                .frame(
                    width: width - borderWidth * 2,
                    height: height - borderWidth * 2
                )
        }
    }
}

/// A button-style pixel container with 3D bevel effect
struct PixelButtonShape: Shape {
    var pixelSize: CGFloat = 4
    var pressed: Bool = false

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Snap rect to pixel grid
        let snappedX = (rect.minX / pixelSize).rounded() * pixelSize
        let snappedY = (rect.minY / pixelSize).rounded() * pixelSize
        let snappedWidth = (rect.width / pixelSize).rounded() * pixelSize
        let snappedHeight = (rect.height / pixelSize).rounded() * pixelSize

        let snappedRect = CGRect(
            x: snappedX,
            y: snappedY,
            width: snappedWidth,
            height: snappedHeight
        )

        path.addRect(snappedRect)
        return path
    }
}

/// Pixel-style 3D button with highlight and shadow
struct PixelButtonStyle: ViewModifier {
    var backgroundColor: Color
    var highlightColor: Color
    var shadowColor: Color
    var pixelSize: CGFloat = 4
    var pressed: Bool

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Shadow layer (offset down-right)
                    PixelRectangle(pixelSize: pixelSize)
                        .fill(shadowColor)
                        .offset(x: pressed ? 0 : pixelSize, y: pressed ? 0 : pixelSize)

                    // Main button layer
                    PixelRectangle(pixelSize: pixelSize)
                        .fill(backgroundColor)
                        .offset(x: pressed ? pixelSize : 0, y: pressed ? pixelSize : 0)

                    // Highlight layer (top-left edge)
                    if !pressed {
                        PixelHighlightShape(pixelSize: pixelSize)
                            .fill(highlightColor)
                    }
                }
            )
    }
}

/// Highlight shape for the top-left edges of pixel buttons
struct PixelHighlightShape: Shape {
    var pixelSize: CGFloat = 4

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let snappedX = (rect.minX / pixelSize).rounded() * pixelSize
        let snappedY = (rect.minY / pixelSize).rounded() * pixelSize
        let snappedWidth = (rect.width / pixelSize).rounded() * pixelSize
        let snappedHeight = (rect.height / pixelSize).rounded() * pixelSize

        // Top edge
        path.addRect(CGRect(
            x: snappedX,
            y: snappedY,
            width: snappedWidth - pixelSize,
            height: pixelSize
        ))

        // Left edge
        path.addRect(CGRect(
            x: snappedX,
            y: snappedY,
            width: pixelSize,
            height: snappedHeight - pixelSize
        ))

        return path
    }
}

// MARK: - Pixel Art Card Back

/// A pixel art pattern for card backs
struct PixelCardBack: View {
    var primaryColor: Color
    var secondaryColor: Color
    var pixelSize: CGFloat = 4

    var body: some View {
        Canvas { context, size in
            let cols = Int(size.width / pixelSize)
            let rows = Int(size.height / pixelSize)

            for row in 0..<rows {
                for col in 0..<cols {
                    // Checkerboard pattern with diagonal stripes
                    let isPrimary = (row + col) % 2 == 0 || (row - col + cols) % 4 == 0

                    let rect = CGRect(
                        x: CGFloat(col) * pixelSize,
                        y: CGFloat(row) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )

                    context.fill(
                        Path(rect),
                        with: .color(isPrimary ? primaryColor : secondaryColor)
                    )
                }
            }
        }
    }
}

// MARK: - Pixel Suit Icons

/// Pixel art representation of card suits
struct PixelSuitIcon: View {
    let suit: Suit
    var size: CGFloat = 24
    var color: Color? = nil

    private var pixelSize: CGFloat { size / 8 }

    var body: some View {
        Canvas { context, canvasSize in
            let pattern = suitPattern
            let pixelW = canvasSize.width / 8
            let pixelH = canvasSize.height / 8

            for (row, rowPixels) in pattern.enumerated() {
                for (col, shouldDraw) in rowPixels.enumerated() {
                    if shouldDraw {
                        let rect = CGRect(
                            x: CGFloat(col) * pixelW,
                            y: CGFloat(row) * pixelH,
                            width: pixelW,
                            height: pixelH
                        )
                        context.fill(Path(rect), with: .color(suitColor))
                    }
                }
            }
        }
        .frame(width: size, height: size)
    }

    private var suitColor: Color {
        color ?? suit.color
    }

    /// 8x8 pixel patterns for each suit
    private var suitPattern: [[Bool]] {
        switch suit {
        case .hearts:
            return [
                [false, false, true,  true,  true,  true,  false, false],
                [false, true,  true,  true,  true,  true,  true,  false],
                [true,  true,  true,  true,  true,  true,  true,  true],
                [true,  true,  true,  true,  true,  true,  true,  true],
                [true,  true,  true,  true,  true,  true,  true,  true],
                [false, true,  true,  true,  true,  true,  true,  false],
                [false, false, true,  true,  true,  true,  false, false],
                [false, false, false, true,  true,  false, false, false]
            ]
        case .diamonds:
            return [
                [false, false, false, true,  true,  false, false, false],
                [false, false, true,  true,  true,  true,  false, false],
                [false, true,  true,  true,  true,  true,  true,  false],
                [true,  true,  true,  true,  true,  true,  true,  true],
                [true,  true,  true,  true,  true,  true,  true,  true],
                [false, true,  true,  true,  true,  true,  true,  false],
                [false, false, true,  true,  true,  true,  false, false],
                [false, false, false, true,  true,  false, false, false]
            ]
        case .clubs:
            return [
                [false, false, true,  true,  true,  true,  false, false],
                [false, true,  true,  true,  true,  true,  true,  false],
                [true,  true,  true,  true,  true,  true,  true,  true],
                [true,  true,  true,  false, false, true,  true,  true],
                [true,  true,  true,  false, false, true,  true,  true],
                [false, false, true,  true,  true,  true,  false, false],
                [false, false, false, true,  true,  false, false, false],
                [false, false, true,  true,  true,  true,  false, false]
            ]
        case .spades:
            return [
                [false, false, false, true,  true,  false, false, false],
                [false, false, true,  true,  true,  true,  false, false],
                [false, true,  true,  true,  true,  true,  true,  false],
                [true,  true,  true,  true,  true,  true,  true,  true],
                [true,  true,  true,  true,  true,  true,  true,  true],
                [false, false, true,  true,  true,  true,  false, false],
                [false, false, true,  true,  true,  true,  false, false],
                [false, true,  true,  false, false, true,  true,  false]
            ]
        }
    }
}

// MARK: - Preview

#Preview("Pixel Shapes") {
    VStack(spacing: 20) {
        PixelRectangle(pixelSize: 4)
            .fill(Color.blue)
            .frame(width: 100, height: 60)

        PixelRectangle(pixelSize: 4)
            .stroke(Color.black, lineWidth: 4)
            .frame(width: 100, height: 60)

        PixelSuitIcon(suit: .hearts, size: 40)
        PixelSuitIcon(suit: .spades, size: 40)
        PixelSuitIcon(suit: .diamonds, size: 40)
        PixelSuitIcon(suit: .clubs, size: 40)

        PixelCardBack(primaryColor: .red, secondaryColor: .darkRed, pixelSize: 4)
            .frame(width: 80, height: 112)
            .border(Color.black, width: 2)
    }
    .padding()
}

extension Color {
    static var darkRed: Color {
        Color(red: 0.5, green: 0, blue: 0)
    }
}
