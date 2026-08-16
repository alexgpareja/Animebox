//
//  WatchingNowEntryView.swift
//  AnimeboxWidget
//

import SwiftUI
import WidgetKit

struct WatchingNowEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WatchingNowEntry

    var body: some View {
        content
            .containerBackground(AppColors.background, for: .widget)
    }

    @ViewBuilder
    private var content: some View {
        if entry.items.isEmpty {
            emptyState
        } else {
            switch family {
            case .systemMedium:
                VStack(alignment: .leading, spacing: AppSpacing.compactSpacing) {
                    ForEach(entry.items.prefix(3)) { item in
                        row(for: item)
                    }
                }
                .padding(AppSpacing.padding)
            default:
                row(for: entry.items[0], showsHeader: true)
                    .padding(AppSpacing.padding)
            }
        }
    }

    private func row(for item: WatchingNowItem, showsHeader: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.microSpacing) {
            if showsHeader {
                Text("Viendo ahora")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Text(item.title)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(showsHeader ? 3 : 1)
            Text(episodeLabel(for: item))
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private func episodeLabel(for item: WatchingNowItem) -> String {
        if let total = item.totalEpisodes {
            String(localized: "Ep. \(item.progress)/\(total)")
        } else {
            String(localized: "Ep. \(item.progress)")
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.microSpacing) {
            Image(systemName: "play.tv")
                .foregroundStyle(AppColors.textSecondary)
            Text("Nada en curso")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
