//
//  CoinDisplay.swift
//  mathgame
//
//  Diamond-shaped coin display
//

import SwiftUI
// Uses global Diamond shape from ShopView.swift or shared shapes file

struct CoinDisplay: View {
    let coins: Int
    var size: CGFloat = 40

    var body: some View {
        HStack(spacing: 8) {
            // Diamond shape
            Diamond()
                .fill(Color(red: 0.9, green: 0.75, blue: 0.2))
                .frame(width: size * 0.6, height: size * 0.6)
                .overlay(
                    Diamond()
                        .stroke(Color.black, lineWidth: 1)
                )

            // Coin count
            Text("\(coins)")
                .font(.system(size: size * 0.5, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.9, green: 0.75, blue: 0.2))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CoinDisplay(coins: 42)
        CoinDisplay(coins: 999, size: 60)
    }
    .padding()
    .background(Color.gray)
}
