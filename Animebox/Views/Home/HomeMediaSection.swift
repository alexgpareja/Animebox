//
//  HomeMediaSection.swift
//  Animebox
//

import SwiftUI

struct HomeMediaSection<Item: MediaSummary>: View {
    let title: String
    let items: [Item]

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
                        ForEach(items) { item in
                            NavigationLink(value: item) {
                                MediaCard(item: item)
                            }
                            .buttonStyle(.pressableCard)
                        }
                    }
                    .padding(.horizontal, AppSpacing.padding)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
