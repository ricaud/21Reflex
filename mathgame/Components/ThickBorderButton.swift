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
        .buttonStyle(PressableButtonStyle(
            isPressed: $isPressed,
            shadowOffset: shadowOffset,
            cornerRadius: cornerRadius,
            borderColor: borderColor
        ))
    }
}

// Custom button style that handles press animation without interfering with tap
struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    var shadowOffset: CGFloat
    var cornerRadius: CGFloat
    var borderColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: isPressed ? shadowOffset : 0)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(borderColor)
                    .offset(y: shadowOffset)
            )
            .onChange(of: configuration.isPressed) { _, newValue in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = newValue
                }
            }
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
