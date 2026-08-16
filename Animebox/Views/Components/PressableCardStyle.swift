//
//  PressableCardStyle.swift
//  Animebox
//

import SwiftUI

/// Feedback táctil sutil al tocar (cards, chips): encoge ligeramente al
/// pulsar, como los controles nativos de iOS. Sustituye a `.buttonStyle(.plain)`
/// allí donde antes no había ningún feedback visual al tocar.
struct PressableCardStyle: ButtonStyle {
    var pressedScale: Double = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableCardStyle {
    static var pressableCard: PressableCardStyle { PressableCardStyle() }
    static func pressableCard(scale: Double) -> PressableCardStyle { PressableCardStyle(pressedScale: scale) }
}
