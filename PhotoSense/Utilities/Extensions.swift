import SwiftUI

// MARK: - View Modifiers

struct CardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(DesignSystem.Radius.medium)
            .shadow(color: DesignSystem.Colors.shadowStrong, radius: 12, x: 0, y: 8)
    }
}

struct GlassEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(DesignSystem.Radius.large)
            .shadow(color: DesignSystem.Colors.shadowStrong, radius: 18, x: 0, y: 12)
    }
}

struct PulseAnimationModifier: ViewModifier {
    @State private var isAnimating: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.03 : 0.97)
            .animation(
                .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyleModifier())
    }

    func glassEffect() -> some View {
        modifier(GlassEffectModifier())
    }

    func pulseAnimation() -> some View {
        modifier(PulseAnimationModifier())
    }
}

// MARK: - Color from hex

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex & 0xFF0000) >> 16) / 255.0
        let g = Double((hex & 0x00FF00) >> 8) / 255.0
        let b = Double(hex & 0x0000FF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    init(hexString: String, alpha: Double = 1.0) {
        var sanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") {
            sanitized.removeFirst()
        }

        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)
        self.init(hex: UInt(value), alpha: alpha)
    }
}
