//
//  AnimeDetailSynopsis.swift
//  Animebox
//

import SwiftUI
import Translation

struct AnimeDetailSynopsis: View {
    let text: String

    @State private var translatedText: String?
    @State private var isTranslating = false
    @State private var translationFailed = false
    @State private var translationConfig: TranslationSession.Configuration?

    private var displayedText: String { translatedText ?? text }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compactSpacing) {
            HStack {
                Text("Sinopsis")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                translateControl
            }
            Text(displayedText)
                .font(.body)
                .foregroundStyle(AppColors.textSecondary)
                .animation(.easeInOut(duration: 0.2), value: displayedText)
            if translationFailed {
                Text("No se pudo traducir la sinopsis.")
                    .font(.caption)
                    .foregroundStyle(AppColors.accent)
            }
        }
        .translationTask(translationConfig) { session in
            await translate(with: session)
        }
    }

    @ViewBuilder
    private var translateControl: some View {
        if isTranslating {
            ProgressView().controlSize(.small)
        } else if translatedText != nil {
            Button("Ver original") { translatedText = nil }
                .font(.caption.weight(.medium))
                .foregroundStyle(AppColors.primary)
        } else {
            Button("Traducir") { startTranslation() }
                .font(.caption.weight(.medium))
                .foregroundStyle(AppColors.primary)
        }
    }

    private func startTranslation() {
        if let cached = SynopsisTranslationCache.storage[text] {
            translatedText = cached
            return
        }
        translationFailed = false
        isTranslating = true
        translationConfig = TranslationSession.Configuration(source: Locale.Language(identifier: "en"))
    }

    private func translate(with session: TranslationSession) async {
        defer { isTranslating = false }
        do {
            try await session.prepareTranslation()
            let response = try await session.translate(text)
            translatedText = response.targetText
            SynopsisTranslationCache.storage[text] = response.targetText
        } catch {
            translationFailed = true
        }
    }
}

/// Las sinopsis de Jikan/MAL vienen siempre en inglés — evita retraducir la
/// misma sinopsis cada vez que se reabre la pantalla de detalle en la misma
/// sesión. Solo en memoria (se pierde al cerrar la app), suficiente para no
/// repetir la llamada al modelo on-device en cada render.
enum SynopsisTranslationCache {
    static var storage: [String: String] = [:]
}

#if DEBUG
#Preview {
    ScrollView {
        AnimeDetailSynopsis(text: "A short synopsis used for previewing the translate button and layout.")
            .padding()
    }
    .background(AppColors.background.ignoresSafeArea())
    .preferredColorScheme(.dark)
}
#endif
