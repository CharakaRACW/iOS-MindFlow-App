import SwiftUI
import CoreData

struct PhotoDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let photo: ClassifiedPhoto

    private var uiImage: UIImage? {
        guard let data = photo.imageData else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let image = uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 240)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(photo.classification ?? "Unknown")
                        .font(.title2.bold())

                    Text((photo.timestamp?.relativeDescription()) ?? "Unknown date")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading) {
                        Text("Confidence")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ProgressView(value: photo.confidence)
                            .tint(.green)

                        Text(ImageClassifier.formattedConfidence(photo.confidence))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 16) {
                    if let image = uiImage {
                        ShareLink(item: Image(uiImage: image), preview: SharePreview(photo.classification ?? "Photo", image: Image(uiImage: image))) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } else {
                        ShareLink(item: photo.classification ?? "Photo") {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }

                    Button(role: .destructive) {
                        deletePhoto()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deletePhoto() {
        withAnimation {
            viewContext.delete(photo)
            do {
                try viewContext.save()
                dismiss()
            } catch {
                // In a production app, surface this error to the user.
                dismiss()
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let request = ClassifiedPhoto.fetchAllSortedByDateRequest()
    let photos = (try? context.fetch(request)) ?? []

    NavigationStack {
        if let first = photos.first {
            PhotoDetailView(photo: first)
                .environment(\.managedObjectContext, context)
        } else {
            Text("No preview data")
        }
    }
}
