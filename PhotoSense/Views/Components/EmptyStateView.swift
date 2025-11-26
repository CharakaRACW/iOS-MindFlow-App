import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 42))
                .foregroundStyle(DesignSystem.Colors.textSecondary)

            VStack(spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.headline)
                Text(message)
                    .font(DesignSystem.Typography.body)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                PrimaryCTAButton(title: actionTitle, systemImage: "camera.fill", isLoading: false, action: action)
                    .frame(maxWidth: 260)
            }
        }
        .padding(DesignSystem.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cardStyle()
        .multilineTextAlignment(.center)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}

#Preview {
    EmptyStateView(
        systemImage: "photo.on.rectangle.angled",
        title: "No history yet",
        message: "Classify a photo to see it appear here.",
        actionTitle: "Classify now"
    ) {}
    .padding()
}
