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
    @Environment(LinkedAccount.self) private var linkedAccount
    @State private var viewModel = ImportListViewModel()
    @State private var isPresentingFilePicker = false

    /// Se dispara tras un import completado con éxito (no al cancelar) — el
    /// presentador la usa para cerrar también la sheet de Ajustes y dejar al
    /// usuario viendo directamente los registros nuevos en la Biblioteca.
    var onImportFinished: () -> Void = {}

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
        case .importing(let current, let total, let kind):
            importingView(current: current, total: total, kind: kind)
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

    private func importingView(current: Int, total: Int, kind: MediaKind) -> some View {
        VStack(spacing: AppSpacing.itemSpacing) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.primary)
            Text(foundText(total: total, kind: kind))
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            ProgressView(value: Double(current), total: Double(max(total, 1)))
                .tint(AppColors.primary)
                .padding(.horizontal, AppSpacing.padding)
            Text("Importando \(current) de \(total)…")
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .monospacedDigit()
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
        }
        .padding(AppSpacing.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
        .accessibilityElement(children: .combine)
        .task {
            // Pausa breve para que el mensaje sea legible (y VoiceOver tenga
            // tiempo de anunciarlo) antes de volver solo a Biblioteca.
            try? await Task.sleep(for: .milliseconds(900))
            onImportFinished()
        }
    }

    private func foundText(total: Int, kind: MediaKind) -> LocalizedStringKey {
        switch kind {
        case .anime: "Se encontraron \(total) animes en el fichero."
        case .manga: "Se encontraron \(total) mangas en el fichero."
        }
    }

    private func handlePickedFile(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            Task {
                let didAccess = url.startAccessingSecurityScopedResource()
                defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
                do {
                    let data = try Data(contentsOf: url)
                    await viewModel.importFile(
                        data: data,
                        service: ContentRouter(account: linkedAccount),
                        coordinator: LibrarySyncCoordinator(context: context, account: linkedAccount)
                    )
                } catch {
                    viewModel.fail(error)
                }
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
        .environment(LinkedAccount(mal: MALSession(), aniList: AniListSession()))
        .preferredColorScheme(.dark)
}
#endif
