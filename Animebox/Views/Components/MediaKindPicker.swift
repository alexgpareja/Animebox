//
//  MediaKindPicker.swift
//  Animebox
//

import SwiftUI

struct MediaKindPicker: View {
    @Binding var selection: MediaKind

    var body: some View {
        Picker("Anime o manga", selection: $selection) {
            ForEach(MediaKind.allCases) { kind in
                Text(kind.displayName).tag(kind)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, AppSpacing.padding)
        .padding(.vertical, AppSpacing.itemSpacing)
        .labelsHidden()
    }
}
