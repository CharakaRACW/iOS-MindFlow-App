import SwiftUI

struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.medium) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                Text(message)
                    .font(DesignSystem.Typography.body)
                    .foregroundStyle(.white)
            }
            .padding(DesignSystem.Spacing.large)
            .background(.ultraThinMaterial)
            .cornerRadius(DesignSystem.Radius.large)
            .shadow(color: DesignSystem.Colors.shadowStrong, radius: 18, x: 0, y: 10)
        }
        .transition(.opacity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        LoadingOverlay(message: "Classifying...")
    }
}
