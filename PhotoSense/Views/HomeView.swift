import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroSection

                    statsSection

                    quickActionsSection

                    recentPhotosSection

                    tipsSection
                }
                .padding()
            }
            .navigationTitle("PhotoSense")
            .toolbarTitleDisplayMode(.inline)
            .task {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Sections

    private var heroSection: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Discover what's in your photos")
                    .font(.largeTitle.bold())
                Text("AI-powered classification")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Your personal photo assistant")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                    .shadow(radius: 10)
                Image(systemName: "brain.head.profile")
                    .foregroundStyle(.white)
                    .imageScale(.large)
            }
            .accessibilityHidden(true)
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    iconName: "number.square",
                    title: "Total Photos",
                    value: "\(viewModel.totalPhotos)",
                    subtitle: nil
                )

                StatCard(
                    iconName: "sparkles",
                    title: "Most Common",
                    value: viewModel.mostCommonClassification ?? "—",
                    subtitle: nil
                )

                StatCard(
                    iconName: "percent",
                    title: "Avg Confidence",
                    value: viewModel.averageConfidence.map { ImageClassifier.formattedConfidence($0) } ?? "—",
                    subtitle: nil
                )

                StatCard(
                    iconName: "calendar",
                    title: "Today",
                    value: "\(viewModel.photosToday)",
                    subtitle: "photos classified"
                )
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            VStack(spacing: 12) {
                NavigationLink {
                    CameraView()
                } label: {
                    QuickActionCard(
                        title: "Classify New Photo",
                        subtitle: "Open the camera to start",
                        systemImage: "camera.fill",
                        gradient: LinearGradient(colors: [.blue.opacity(0.9), .purple.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {}
                }

                NavigationLink {
                    HistoryView()
                } label: {
                    QuickActionCard(
                        title: "View History",
                        subtitle: "Browse your past classifications",
                        systemImage: "clock.arrow.circlepath",
                        gradient: LinearGradient(colors: [.green.opacity(0.9), .teal.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {}
                }
            }
        }
    }

    private var recentPhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Photos")
                .font(.headline)

            if viewModel.recentPhotos.isEmpty {
                Text("Classify a photo to see it here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.recentPhotos) { photo in
                            NavigationLink {
                                PhotoDetailView(photo: photo)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    if let data = photo.imageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color.secondary.opacity(0.15))
                                            Image(systemName: "photo")
                                                .foregroundStyle(.secondary)
                                        }
                                        .frame(width: 120, height: 120)
                                    }

                                    Text(photo.classification ?? "Unknown")
                                        .font(.caption.bold())
                                        .lineLimit(1)
                                    Text(photo.timestamp?.relativeDescription() ?? "Unknown date")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tips for better results")
                .font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                Label("Ensure good lighting and avoid motion blur.", systemImage: "lightbulb")
                Label("Fill the frame with the main subject.", systemImage: "viewfinder")
                Label("Try multiple angles if results are uncertain.", systemImage: "arrow.triangle.2.circlepath.camera")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
