//
//  SyncStatusIndicator.swift
//  21Reflex
//
//  Visual indicator for iCloud sync status
//

import SwiftUI

struct SyncStatusIndicator: View {
    @State private var syncManager = SyncManager.shared

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: syncManager.state.iconName)
                .font(.caption)
            Text(syncManager.state.description)
                .font(.caption2)
        }
        .foregroundColor(syncManager.state.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(syncManager.state.color.opacity(0.15))
        )
        .overlay(
            Capsule()
                .stroke(syncManager.state.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 10) {
        SyncStatusIndicator()
    }
    .padding()
}
