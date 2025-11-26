import SwiftUI

struct StatCard: View {
    let iconName: String
    let title: String
    let value: String
    let subtitle: String?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: iconName)
                        .imageScale(.large)
                        .foregroundStyle(DesignSystem.Colors.primaryStart)
                    Spacer()
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(value)
                    .font(.title2.bold())
                    .minimumScaleFactor(0.6)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    StatCard(iconName: "number.square", title: "Total Photos", value: "42", subtitle: "Since Oct 2025")
        .padding()
}
