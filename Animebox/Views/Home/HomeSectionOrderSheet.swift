//
//  HomeSectionOrderSheet.swift
//  Animebox
//

import SwiftUI

/// Arrastra las 3 secciones de Inicio para reordenarlas — el modo edición
/// se fuerza activo (`.constant(.active)`) para que los tiradores de
/// arrastre estén siempre visibles, sin un botón "Editar" intermedio.
struct HomeSectionOrderSheet: View {
    let mediaKind: MediaKind
    let settings: HomeSectionOrderSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(settings.order(for: mediaKind)) { slot in
                    Text(slot.title(for: mediaKind))
                        .foregroundStyle(AppColors.textPrimary)
                }
                .onMove { offsets, destination in
                    settings.move(kind: mediaKind, from: offsets, to: destination)
                }
                .listRowBackground(AppColors.cardBackground)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Ordenar Inicio")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#if DEBUG
#Preview {
    HomeSectionOrderSheet(mediaKind: .anime, settings: HomeSectionOrderSettings())
        .preferredColorScheme(.dark)
}
#endif
