//
//  MangaStatusPicker.swift
//  Animebox
//

import SwiftUI

struct MangaStatusPicker: View {
    @Binding var selection: MangaStatus

    var body: some View {
        Picker("Estado", selection: $selection) {
            ForEach(MangaStatus.allCases) { status in
                Text(status.displayName).tag(status)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, AppSpacing.padding)
        .padding(.vertical, AppSpacing.itemSpacing)
    }
}
