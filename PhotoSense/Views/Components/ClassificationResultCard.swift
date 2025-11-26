import SwiftUI

struct ClassificationResultCard: View {
    let classification: String
    let confidence: Double

    @State private var animateAppearance: Bool = false

    private var confidenceColor: Color {
        switch confidence {
        case let value where value >= 0.8:
            return .green
        case let value where value >= 0.5:
            return .yellow
        default:
            return .red
        }
    }

    var body: some View {
        ZStack {
            // Glassmorphism-style background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 18, x: 0, y: 12)

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8)
                        .foregroundStyle(Color.gray.opacity(0.2))

                    Circle()
                        .trim(from: 0, to: animateAppearance ? CGFloat(confidence) : 0)
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .foregroundStyle(confidenceColor)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.8), value: animateAppearance)

                    VStack(spacing: 2) {
                        Text(ImageClassifier.formattedConfidence(confidence))
                            .font(.caption.bold())
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(confidenceColor)
                            .imageScale(.small)
                    }
                }
                .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 6) {
                    Text(classification)
                        .font(.title3.bold())
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)

                    Text("Classification result")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(16)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Classification: \(classification), confidence \(ImageClassifier.formattedConfidence(confidence))")
        .onAppear {
            animateAppearance = true
        }
    }
}

#Preview {
    ClassificationResultCard(classification: "Golden Retriever", confidence: 0.93)
        .padding()
}
