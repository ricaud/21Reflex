//
//  PlayingCardView.swift
//  21Reflex
//
//  Native SwiftUI playing card with animations
//

import SwiftUI

struct PlayingCardView: View {
    let card: Card
    var isFaceDown: Bool = false
    var animateOnAppear: Bool = false

    @State private var slideOffset: CGFloat = 100
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 10)
                .fill(isFaceDown ? Color(red: 0.2, green: 0.3, blue: 0.6) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )

            if !isFaceDown {
                // Card face
                VStack(spacing: 0) {
                    // Top-left corner
                    HStack(spacing: 2) {
                        Text(card.rank.rawValue)
                            .font(.system(size: 14, weight: .bold))
                        Text(card.suit.rawValue)
                            .font(.system(size: 12))
                        Spacer()
                    }
                    .foregroundStyle(card.suit.color)

                    Spacer()

                    // Center suit (large)
                    Text(card.suit.rawValue)
                        .font(.system(size: 32))
                        .foregroundStyle(card.suit.color)

                    Spacer()

                    // Bottom-right corner (inverted)
                    HStack(spacing: 2) {
                        Spacer()
                        Text(card.suit.rawValue)
                            .font(.system(size: 12))
                        Text(card.rank.rawValue)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(card.suit.color)
                    .rotationEffect(.degrees(180))
                }
                .padding(6)
            } else {
                // Card back pattern
                VStack(spacing: 4) {
                    ForEach(0..<3) { _ in
                        HStack(spacing: 4) {
                            ForEach(0..<3) { _ in
                                Circle()
                                    .fill(Color(red: 0.9, green: 0.9, blue: 0.95))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
            }
        }
        .offset(x: animateOnAppear ? slideOffset : 0)
        .scaleEffect(animateOnAppear ? scale : 1.0)
        .opacity(animateOnAppear ? opacity : 1.0)
        .onAppear {
            if animateOnAppear {
                withAnimation(.easeOut(duration: 0.35)) {
                    slideOffset = 0
                    scale = 1.0
                    opacity = 1
                }
            }
        }
    }
}

#Preview {
    HStack(spacing: -20) {
        PlayingCardView(card: Card(suit: .hearts, rank: .ace))
        PlayingCardView(card: Card(suit: .spades, rank: .ten))
        PlayingCardView(card: Card(suit: .diamonds, rank: .king))
    }
    .padding()
}
