//
//  StatsView.swift
//  Animebox
//

import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var animeEntries: [LibraryEntry]
    @Query private var mangaEntries: [MangaLibraryEntry]

    private var stats: LibraryStats {
        LibraryStatsQuery.makeStats(animeEntries: animeEntries, mangaEntries: mangaEntries)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                headlineGrid
                if !stats.animeStatusCounts.isEmpty {
                    statusSection(title: "Anime por estado", rows: animeStatusRows)
                }
                if !stats.mangaStatusCounts.isEmpty {
                    statusSection(title: "Manga por estado", rows: mangaStatusRows)
                }
                if !stats.topAnimeGenres.isEmpty {
                    genreSection(title: "Géneros de anime más vistos", genres: stats.topAnimeGenres)
                }
                if !stats.topMangaGenres.isEmpty {
                    genreSection(title: "Géneros de manga más leídos", genres: stats.topMangaGenres)
                }
            }
            .padding(AppSpacing.padding)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Estadísticas")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }

    private var headlineGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.itemSpacing) {
            statCard(value: "\(stats.totalAnimeEntries)", label: "Anime en biblioteca", systemImage: "tv")
            statCard(value: "\(stats.totalMangaEntries)", label: "Manga en biblioteca", systemImage: "book")
            statCard(value: "\(stats.totalEpisodesWatched)", label: "Episodios vistos", systemImage: "play.rectangle")
            statCard(value: "\(stats.totalChaptersRead)", label: "Capítulos leídos", systemImage: "book.pages")
            statCard(value: watchTimeLabel, label: "Tiempo estimado viendo", systemImage: "clock")
            statCard(value: scoreLabel, label: "Valoración media", systemImage: "star.fill")
        }
    }

    private var watchTimeLabel: String {
        let hours = stats.estimatedWatchTimeMinutes / 60
        return String(format: AppLanguage.current.string("%lld h"), hours)
    }

    private var animeStatusRows: [(label: String, count: Int)] {
        LibraryStatus.allCases
            .compactMap { status in (stats.animeStatusCounts[status] ?? 0) > 0 ? (status.displayName, stats.animeStatusCounts[status] ?? 0) : nil }
    }

    private var mangaStatusRows: [(label: String, count: Int)] {
        MangaStatus.allCases
            .compactMap { status in (stats.mangaStatusCounts[status] ?? 0) > 0 ? (status.displayName, stats.mangaStatusCounts[status] ?? 0) : nil }
    }

    private var scoreLabel: String {
        let scores = [stats.averageAnimeScore, stats.averageMangaScore].compactMap { $0 }
        guard !scores.isEmpty else { return "—" }
        let overall = scores.reduce(0, +) / Double(scores.count)
        return String(format: "%.1f", overall)
    }

    private func statCard(value: String, label: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.microSpacing) {
            Image(systemName: systemImage)
                .foregroundStyle(AppColors.primary)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.padding)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
    }

    private func statusSection(title: String, rows: [(label: String, count: Int)]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.itemSpacing) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Chart(rows, id: \.label) { row in
                BarMark(
                    x: .value("Cantidad", row.count),
                    y: .value("Estado", row.label)
                )
                .foregroundStyle(AppColors.primary)
            }
            .frame(height: CGFloat(rows.count) * 36 + 20)
        }
        .padding(AppSpacing.padding)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
    }

    private func genreSection(title: String, genres: [GenreCount]) -> some View {
        let top = Array(genres.prefix(8))
        return VStack(alignment: .leading, spacing: AppSpacing.itemSpacing) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Chart(top) { genre in
                BarMark(
                    x: .value("Cantidad", genre.count),
                    y: .value("Género", GenreLocalization.localizedName(for: genre.name))
                )
                .foregroundStyle(AppColors.secondary)
            }
            .frame(height: CGFloat(top.count) * 36 + 20)
        }
        .padding(AppSpacing.padding)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        StatsView()
    }
    .modelContainer(PreviewLibrary.makeContainer())
    .preferredColorScheme(.dark)
}
#endif
