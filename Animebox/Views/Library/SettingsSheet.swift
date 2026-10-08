//
//  SettingsSheet.swift
//  Animebox
//

import SwiftUI
import SwiftData

/// Pantalla de ajustes de `LibraryView` — hoy cubre cuenta (MAL o AniList,
/// excluyentes) y datos (import XML), pero es el punto de entrada natural
/// para lo que se añada más adelante (apariencia, notificaciones...): cada
/// nueva opción es una `Section` más en este mismo `Form`, no una pantalla
/// nueva.
struct SettingsSheet: View {
    @State private var viewModel: AccountViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AppLanguageSettings.self) private var languageSettings
    @State private var isPresentingImport = false

    init(viewModel: AccountViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        // `.navigationTitle` no reevalúa su LocalizedStringKey en vivo solo
        // por un cambio de `.environment(\.locale:)` — forzar la identidad
        // del NavigationStack a cambiar con el idioma es el workaround para
        // que el título de la barra de navegación también se actualice al
        // momento en vez de solo en la próxima apertura de la sheet.
        NavigationStack {
            Form {
                if viewModel.account.isSignedIn {
                    signedInSection
                } else {
                    signedOutSection
                    // Con sesión iniciada, el reconciler del proveedor ya
                    // trae la lista real automáticamente y cada cambio se
                    // sincroniza en vivo — reimportar el XML de la misma
                    // cuenta sobre sí misma no aporta nada, solo confunde.
                    dataSection
                }
                statsSection
                languageSection
            }
            .navigationTitle("Ajustes")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .sheet(isPresented: $isPresentingImport) {
                ImportListSheet(onImportFinished: {
                    isPresentingImport = false
                    dismiss()
                })
            }
            .task { await viewModel.refreshUsernameIfNeeded() }
        }
        .id(languageSettings.language)
    }

    private var signedOutSection: some View {
        Section("Cuenta") {
            VStack(alignment: .leading, spacing: AppSpacing.itemSpacing) {
                Text("Inicia sesión con tu cuenta de MyAnimeList o AniList para que Buscar e Inicio usen la API oficial (no depende de que Tenrai esté caído) y tu lista se sincronice con tu cuenta real.")
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                if viewModel.isLoading {
                    ProgressView("Iniciando sesión…")
                        .frame(maxWidth: .infinity)
                } else {
                    Button("Iniciar sesión con MyAnimeList") {
                        Task { await viewModel.signInMAL(context: context) }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primary)
                    .frame(maxWidth: .infinity)

                    Button("Iniciar sesión con AniList") {
                        Task { await viewModel.signInAniList(context: context) }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.secondary)
                    .frame(maxWidth: .infinity)
                }
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(AppColors.accent)
                }
            }
            .padding(.vertical, AppSpacing.compactSpacing)
        }
    }

    private var signedInSection: some View {
        Section("Cuenta") {
            if let username = activeUsername {
                Label("Conectado a \(activeProviderName) como \(username)", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(AppColors.textPrimary)
            } else {
                Label("Conectado a \(activeProviderName)", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(AppColors.textPrimary)
            }
            if let lastSyncError = viewModel.account.lastSyncError {
                Label(lastSyncError, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(AppColors.accent)
            }
            Button("Cerrar sesión", role: .destructive) {
                viewModel.signOut()
            }
        }
    }

    private var activeUsername: String? {
        switch viewModel.account.activeProvider {
        case .mal: viewModel.account.mal.username
        case .aniList: viewModel.account.aniList.username
        case nil: nil
        }
    }

    private var activeProviderName: String {
        switch viewModel.account.activeProvider {
        case .mal: "MyAnimeList"
        case .aniList: "AniList"
        case nil: ""
        }
    }

    private var dataSection: some View {
        Section("Datos") {
            Button {
                isPresentingImport = true
            } label: {
                Label("Importar lista de MyAnimeList (XML)", systemImage: "square.and.arrow.down")
            }
        }
    }

    private var statsSection: some View {
        Section {
            NavigationLink {
                StatsView()
            } label: {
                Label("Estadísticas", systemImage: "chart.bar.xaxis")
            }
        }
    }

    private var languageSection: some View {
        Section("Idioma") {
            Picker("Idioma", selection: Bindable(languageSettings).language) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.displayName).tag(language)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }
}

#if DEBUG
#Preview {
    SettingsSheet(viewModel: AccountViewModel(account: LinkedAccount(mal: MALSession(), aniList: AniListSession())))
        .modelContainer(for: [LibraryEntry.self, MangaLibraryEntry.self], inMemory: true)
        .environment(AppLanguageSettings())
        .preferredColorScheme(.dark)
}
#endif
