//
//  LibraryStatusPicker.swift
//  Animebox
//

import SwiftUI

struct LibraryStatusPicker: View {
    @Binding var selection: LibraryStatus

    var body: some View {
        Picker("Estado", selection: $selection) {
            ForEach(LibraryStatus.allCases) { status in
                Text(status.displayName).tag(status)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, AppSpacing.padding)
        .padding(.vertical, AppSpacing.itemSpacing)
    }
}
