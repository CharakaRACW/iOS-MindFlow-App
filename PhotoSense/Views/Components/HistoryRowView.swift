import SwiftUI
import CoreData

struct HistoryRowView: View {
    let photo: ClassifiedPhoto

    private var thumbnailImage: Image {
        if let data = photo.imageData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "photo")
        }
    }

    private var confidenceColor: Color {
        switch photo.confidence {
        case let value where value >= 0.8:
            return .green
        case let value where value >= 0.5:
            return .yellow
        default:
            return .red
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            thumbnailImage
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(photo.classification ?? "Unknown")
                    .font(.headline)
                    .lineLimit(1)
                Text(photo.timestamp?.relativeDescription() ?? "Unknown date")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(ImageClassifier.formattedConfidence(photo.confidence))
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(confidenceColor.opacity(0.15))
                .foregroundStyle(confidenceColor)
                .clipShape(Capsule())

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let request = ClassifiedPhoto.fetchAllSortedByDateRequest()
    let photos = (try? context.fetch(request)) ?? []

    NavigationStack {
        List(photos.prefix(1), id: \.self) { photo in
            HistoryRowView(photo: photo)
        }
    }
}
