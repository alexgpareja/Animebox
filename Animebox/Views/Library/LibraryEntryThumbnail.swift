//
//  LibraryEntryThumbnail.swift
//  Animebox
//

import SwiftUI

struct LibraryEntryThumbnail: View {
    let imageURL: String?
    var width: Double = 60

    var body: some View {
        Group {
            if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        PosterPlaceholder()
                    case .empty:
                        AppColors.cardBackground
                            .overlay { ProgressView().tint(AppColors.primary) }
                    @unknown default:
                        AppColors.cardBackground
                    }
                }
            } else {
                PosterPlaceholder()
            }
        }
        .frame(width: width, height: width * 1.4)
        .clipped()
        .clipShape(.rect(cornerRadius: 8))
    }
}
