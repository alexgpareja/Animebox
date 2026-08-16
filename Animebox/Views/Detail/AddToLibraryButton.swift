//
//  AddToLibraryButton.swift
//  Animebox
//

import SwiftUI

struct AddToLibraryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "plus.circle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppColors.primary)
        .controlSize(.large)
    }
}
