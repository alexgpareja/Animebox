//
//  AccountViewModel.swift
//  Animebox
//

import Foundation
import SwiftData

@Observable
@MainActor
final class AccountViewModel {
    private(set) var isLoading = false
    var errorMessage: String?
    let account: LinkedAccount

    init(account: LinkedAccount) {
        self.account = account
    }

    func signInMAL(context: ModelContext) async {
        await signIn(context: context) {
            try await self.account.mal.signIn()
            async let username: Void = self.fetchMALUsername()
            try await MALSyncReconciler(context: context, session: self.account.mal).reconcile()
            await username
        }
    }

    func signInAniList(context: ModelContext) async {
        await signIn(context: context) {
            try await self.account.aniList.signIn()
            async let username: Void = self.fetchAniListUsername()
            try await AniListSyncReconciler(context: context, session: self.account.aniList).reconcile()
            await username
        }
    }

    func signOut() {
        switch account.activeProvider {
        case .mal: account.mal.signOut()
        case .aniList: account.aniList.signOut()
        case nil: break
        }
    }

    /// El username solo se guarda en memoria (`MALSession`/`AniListSession`
    /// no lo persisten), así que tras un arranque en frío con sesión ya
    /// iniciada (token en Keychain) queda `nil` hasta volver a pedirlo —
    /// `SettingsSheet` llama esto al aparecer para rellenarlo sin esperar a
    /// un nuevo sign-in.
    func refreshUsernameIfNeeded() async {
        switch account.activeProvider {
        case .mal where account.mal.username == nil: await fetchMALUsername()
        case .aniList where account.aniList.username == nil: await fetchAniListUsername()
        default: break
        }
    }

    private func signIn(context: ModelContext, action: @escaping () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await action()
        } catch MALAuthError.cancelled, AniListAuthError.cancelled {
            // El usuario cerró la ventana de login, no es un error que mostrar.
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func fetchMALUsername() async {
        let api = MALAPIService(malSession: account.mal)
        let url = MALConfig.baseURL.appendingPathComponent("users/@me")
        guard let profile = try? await api.get(url, as: MALUserProfile.self) else { return }
        account.mal.setUsername(profile.name)
    }

    private func fetchAniListUsername() async {
        let api = AniListAPIService(aniListSession: account.aniList)
        guard let response = try? await api.graphQL(
            query: "query { Viewer { id name } }", authenticated: true, as: AniListViewerResponse.self
        ) else { return }
        account.aniList.setUsername(response.Viewer.name)
    }
}

private nonisolated struct MALUserProfile: Decodable, Sendable {
    let name: String
}
