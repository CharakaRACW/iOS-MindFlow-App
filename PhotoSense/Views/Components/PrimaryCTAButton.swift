import SwiftUI

struct PrimaryCTAButton: View {
    let title: String
    let systemImage: String?
    let isLoading: Bool
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button {
            guard !isLoading else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let systemImage = systemImage {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .font(DesignSystem.Typography.button)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.medium)
            .foregroundStyle(.white)
            .background(DesignSystem.Colors.primaryGradient)
            .cornerRadius(DesignSystem.Radius.large)
            .shadow(color: DesignSystem.Colors.shadowStrong, radius: 14, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    VStack {
        PrimaryCTAButton(title: "Classify", systemImage: "sparkles", isLoading: false) {}
        PrimaryCTAButton(title: "Saving...", systemImage: nil, isLoading: true) {}
    }
    .padding()
}
