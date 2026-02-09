//
//  GameCard.swift
//  mathgame
//
//  Card component for buffs and themes
//

import SwiftUI

struct GameCard: View {
    let title: String
    let description: String
    let icon: String
    var isSelected: Bool = false
    var status: CardStatus = .selectable
    var action: () -> Void

    enum CardStatus {
        case selectable
        case owned
        case equipped
        case locked(cost: Int)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(iconColor)
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Status indicator
                statusView
            }
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 4 : 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var iconColor: Color {
        switch status {
        case .locked:
            return .gray
        default:
            return .accentColor
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .equipped:
            return Color.green.opacity(0.1)
        case .owned:
            return Color.gray.opacity(0.1)
        case .locked:
            return Color.gray.opacity(0.05)
        default:
            return Color.white
        }
    }

    private var borderColor: Color {
        switch status {
        case .equipped:
            return .green
        case .owned:
            return .gray
        case .locked:
            return .gray.opacity(0.5)
        default:
            return isSelected ? .accentColor : .gray.opacity(0.5)
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch status {
        case .equipped:
            Text("EQUIPPED")
                .font(.caption.bold())
                .foregroundStyle(.green)
        case .owned:
            Text("OWNED")
                .font(.caption)
                .foregroundStyle(.gray)
        case .locked(let cost):
            HStack(spacing: 4) {
                Image(systemName: "diamond.fill")
                    .foregroundStyle(Color(red: 0.9, green: 0.75, blue: 0.2))
                Text("\(cost)")
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
            }
        default:
            EmptyView()
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        GameCard(
            title: "Extra Time",
            description: "+3 seconds per question",
            icon: "clock.fill",
            action: {}
        )

        GameCard(
            title: "Coin Multiplier",
            description: "2× coins earned",
            icon: "dollarsign.circle.fill",
            isSelected: true,
            action: {}
        )

        GameCard(
            title: "Candy Theme",
            description: "Sweet pink and purple colors",
            icon: "paintpalette.fill",
            status: .locked(cost: 100),
            action: {}
        )

        GameCard(
            title: "Ocean Theme",
            description: "Calm blue and teal colors",
            icon: "paintpalette.fill",
            status: .owned,
            action: {}
        )
    }
    .padding()
}
