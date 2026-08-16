//
//  ImportListSheet.swift
//  Animebox
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportListSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ImportListViewModel()
    @State private var isPresentingFilePicker = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Importar de MyAnimeList")
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cerrar") { dismiss() }
                    }
                }
        }
        .fileImporter(isPresented: $isPresentingFilePicker, allowedContentTypes: [.xml]) { result in
            handlePickedFile(result)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            idleView
        case .parsed(let result):
            parsedView(result)
        case .importing:
            LoadingView()
        case .done(let count):
            doneView(count: count)
        case .error(let message):
            ErrorView(message: message) {
                isPresentingFilePicker = true
            }
        }
    }

    private var idleView: some View {
        VStack(spacing: AppSpacing.itemSpacing) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.primary)
            Text("Importa tu lista de MyAnimeList")
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)
            Text("Exporta tu lista de anime o manga desde la web de MyAnimeList (Ajustes → Import/Export) y elige aquí el fichero .xml. Puedes repetir el proceso una vez por cada lista.")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.padding)
            Button("Elegir fichero XML") {
                isPresentingFilePicker = true
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primary)
        }
        .padding(AppSpacing.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
    }

    private func parsedView(_ result: MALImportResult) -> some View {
        VStack(spacing: AppSpacing.itemSpacing) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.primary)
            Text(summaryText(for: result))
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            Button("Importar") {
                Task { await viewModel.commitImport(context: context) }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primary)
        }
        .padding(AppSpacing.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
    }

    private func doneView(count: Int) -> some View {
        VStack(spacing: AppSpacing.itemSpacing) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.primary)
            Text("\(count) series importadas")
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)
            Button("Listo") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
        }
        .padding(AppSpacing.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
    }

    private func summaryText(for result: MALImportResult) -> LocalizedStringKey {
        switch result {
        case .anime(let entries):
            "Se encontraron \(entries.count) animes en el fichero."
        case .manga(let entries):
            "Se encontraron \(entries.count) mangas en el fichero."
        }
    }

    private func handlePickedFile(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let didAccess = url.startAccessingSecurityScopedResource()
            defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                viewModel.parse(data: data)
            } catch {
                viewModel.fail(error)
            }
        case .failure(let error):
            viewModel.fail(error)
        }
    }
}

#if DEBUG
#Preview {
    ImportListSheet()
        .modelContainer(for: [LibraryEntry.self, MangaLibraryEntry.self], inMemory: true)
        .preferredColorScheme(.dark)
}
#endif
