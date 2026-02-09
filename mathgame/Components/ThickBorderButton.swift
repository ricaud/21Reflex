//
//  ThickBorderButton.swift
//  mathgame
//
//  Custom button with thick border and shadow offset
//

import SwiftUI

struct ThickBorderButton: View {
    let title: String
    let action: () -> Void
    var bgColor: Color = .gray
    var textColor: Color = .white
    var borderColor: Color = .black
    var borderWidth: CGFloat = 4
    var shadowOffset: CGFloat = 5
    var cornerRadius: CGFloat = 12
    var font: Font = .title2.bold()

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundStyle(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(bgColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .offset(y: isPressed ? shadowOffset : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(borderColor)
                .offset(y: shadowOffset)
        )
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// Helper for press detection
struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

#Preview {
    VStack(spacing: 20) {
        ThickBorderButton(title: "PLAY", action: {})
            .frame(width: 200, height: 60)

        ThickBorderButton(
            title: "SETTINGS",
            action: {},
            bgColor: .blue,
            textColor: .white,
            borderColor: .black
        )
        .frame(width: 200, height: 50)

        ThickBorderButton(
            title: "HARD MODE",
            action: {},
            bgColor: .red,
            textColor: .white,
            borderColor: .black
        )
        .frame(width: 200, height: 50)
    }
    .padding()
}
