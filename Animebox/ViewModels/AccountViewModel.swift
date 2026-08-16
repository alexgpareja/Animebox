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
    let session: MALSession

    init(session: MALSession) {
        self.session = session
    }

    func signIn(context: ModelContext) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await session.signIn()
            async let username: Void = fetchUsername()
            try await MALSyncReconciler(context: context, session: session).reconcile()
            await username
        } catch MALAuthError.cancelled {
            // El usuario cerró la ventana de login, no es un error que mostrar.
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func signOut() {
        session.signOut()
    }

    private func fetchUsername() async {
        let api = MALAPIService(malSession: session)
        let url = MALConfig.baseURL.appendingPathComponent("users/@me")
        guard let profile = try? await api.get(url, as: MALUserProfile.self) else { return }
        session.setUsername(profile.name)
    }
}

private nonisolated struct MALUserProfile: Decodable, Sendable {
    let name: String
}
