//
//  AccountSheet.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct AccountSheet: View {
    @State private var viewModel: AccountViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AccountViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                if viewModel.session.isSignedIn {
                    signedInSection
                } else {
                    signedOutSection
                }
                if let lastSyncError = viewModel.session.lastSyncError {
                    Section("Último aviso de sincronización") {
                        Text(lastSyncError)
                            .foregroundStyle(AppColors.accent)
                    }
                }
            }
            .navigationTitle("Cuenta")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }

    private var signedOutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: AppSpacing.itemSpacing) {
                Text("Inicia sesión con tu cuenta de MyAnimeList para que Buscar e Inicio usen la API oficial (no depende de que Jikan esté caído) y tu lista se sincronice con tu cuenta real.")
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                if viewModel.isLoading {
                    ProgressView("Iniciando sesión…")
                        .frame(maxWidth: .infinity)
                } else {
                    Button("Iniciar sesión con MyAnimeList") {
                        Task { await viewModel.signIn(context: context) }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primary)
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
        Section {
            if let username = viewModel.session.username {
                Label("Conectado como \(username)", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(AppColors.textPrimary)
            } else {
                Label("Conectado con MyAnimeList", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(AppColors.textPrimary)
            }
            Button("Cerrar sesión", role: .destructive) {
                viewModel.signOut()
            }
        }
    }
}

#if DEBUG
#Preview {
    AccountSheet(viewModel: AccountViewModel(session: MALSession()))
        .modelContainer(for: [LibraryEntry.self, MangaLibraryEntry.self], inMemory: true)
        .preferredColorScheme(.dark)
}
#endif
