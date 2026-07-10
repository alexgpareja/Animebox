//
//  HomeAnimeSection.swift
//  Animebox
//

import SwiftUI

struct HomeAnimeSection: View {
    let title: String
    let items: [Anime]

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.itemSpacing) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, AppSpacing.padding)

                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: AppSpacing.itemSpacing) {
                        ForEach(items) { anime in
                            NavigationLink(value: anime) {
                                AnimeCard(anime: anime)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppSpacing.padding)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
