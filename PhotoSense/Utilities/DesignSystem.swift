import SwiftUI

enum DesignSystem {
    enum Colors {
        // Brand colors
        static let psBlue = Color(hex: 0x007AFF)
        static let psPurple = Color(hex: 0x5856D6)
        static let psGreen = Color(hex: 0x34C759)
        static let psOrange = Color(hex: 0xFF9500)

        static let primaryStart = psBlue
        static let primaryEnd = psPurple
        static let secondary = psPurple
        static let success = psGreen
        static let warning = Color.yellow
        static let error = Color.red

        static let background = Color(UIColor.systemBackground)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary

        static let strokeMuted = Color.gray.opacity(0.25)
        static let shadowStrong = Color.black.opacity(0.25)

        static let primaryGradient = LinearGradient(
            colors: [primaryStart, primaryEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum Typography {
        static let title = Font.system(.title, design: .rounded).weight(.bold)
        static let headline = Font.system(.headline, design: .rounded)
        static let body = Font.system(.body, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded)
        static let button = Font.system(.headline, design: .rounded).weight(.semibold)
    }

    enum Spacing {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
    }

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 14
        static let large: CGFloat = 20
    }

    enum Shadows {
        static let card = ShadowStyle(color: Colors.shadowStrong, radius: 12, x: 0, y: 8)
    }
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
