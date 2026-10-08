//
//  RelatedMediaSection.swift
//  Animebox
//

import SwiftUI

/// Bloque "Relacionados" después de la sinopsis — temporadas
/// anteriores/siguientes, precuelas/secuelas, historias paralelas...
/// Reutiliza `MediaCard`/`NavigationLink(value:)` tal cual, así que el push
/// al detalle de la entrada relacionada usa el mismo `.navigationDestination`
/// ya registrado en la raíz de cada pestaña — sin cableado extra.
struct RelatedMediaSection<Item: MediaSummary & Hashable>: View {
    let entries: [RelatedEntry]
    let makeItem: (RelatedEntry) -> Item

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.itemSpacing) {
                Text("Relacionados")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)

                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: AppSpacing.itemSpacing) {
                        ForEach(entries) { entry in
                            let item = makeItem(entry)
                            NavigationLink(value: item) {
                                VStack(alignment: .leading, spacing: AppSpacing.microSpacing) {
                                    MediaCard(item: item, width: 120)
                                    Text(RelationTypeLocalization.localizedName(for: entry.relation))
                                        .font(.caption2)
                                        .foregroundStyle(AppColors.accent)
                                        .lineLimit(1)
                                        .frame(width: 120, alignment: .leading)
                                }
                            }
                            .buttonStyle(.pressableCard)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

#if DEBUG
#Preview {
    RelatedMediaSection(
        entries: [
            RelatedEntry(malId: 1, title: "Attack on Titan Season 2", imageURL: nil, relation: "Prequel"),
            RelatedEntry(malId: 2, title: "Attack on Titan: The Final Season", imageURL: nil, relation: "Sequel")
        ]
    ) { Anime(relatedEntry: $0) }
        .padding()
        .background(AppColors.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
}
#endif
