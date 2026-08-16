//
//  RemoteImage.swift
//  Animebox
//
//  Loader de imagen remoto basado en URLSession. AsyncImage se queda a veces
//  en `.failure` cuando hay muchas cargas concurrentes en LazyHStack; esto
//  usa `.task(id:)` para respetar cancelación y no compartir la cola interna
//  de AsyncImage.
//

import SwiftUI

struct RemoteImage: View {
    let url: URL?

    @State private var image: Image?
    @State private var failed = false

    var body: some View {
        Group {
            if let image {
                image.resizable().scaledToFill()
            } else if failed || url == nil {
                PosterPlaceholder()
            } else {
                AppColors.cardBackground
                    .overlay { ProgressView().tint(AppColors.primary) }
            }
        }
        .task(id: url) {
            await load()
        }
    }

    private func load() async {
        image = nil
        failed = false
        guard let url else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            try Task.checkCancellation()
            if let loaded = Self.platformImage(from: data) {
                image = loaded
            } else {
                failed = true
            }
        } catch is CancellationError {
            // ignore
        } catch {
            failed = true
        }
    }

    private static func platformImage(from data: Data) -> Image? {
#if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
#elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
#endif
        return nil
    }
}
