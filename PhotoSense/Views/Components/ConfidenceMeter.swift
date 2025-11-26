import SwiftUI

struct ConfidenceMeter: View {
    let value: Double // 0...1

    @State private var animate: Bool = false

    private var clampedValue: Double {
        min(max(value, 0), 1)
    }

    private var color: Color {
        switch clampedValue {
        case let x where x >= 0.8:
            return DesignSystem.Colors.success
        case let x where x >= 0.5:
            return DesignSystem.Colors.warning
        default:
            return DesignSystem.Colors.error
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Colors.strokeMuted, lineWidth: 8)

            Circle()
                .trim(from: 0, to: animate ? clampedValue : 0)
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .foregroundStyle(color)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: animate)

            Text(ImageClassifier.formattedConfidence(clampedValue))
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
        .onAppear { animate = true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Confidence \(ImageClassifier.formattedConfidence(clampedValue))")
    }
}

#Preview {
    ConfidenceMeter(value: 0.86)
        .frame(width: 80, height: 80)
        .padding()
}
