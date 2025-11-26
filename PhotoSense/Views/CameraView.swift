import SwiftUI
import UIKit

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        VStack(spacing: 20) {
            imagePreview

            actionButtons

            if let result = viewModel.classificationResult,
               let confidence = viewModel.confidence {
                ClassificationResultCard(classification: result, confidence: confidence)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Camera")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    Task { await viewModel.saveToHistory() }
                } label: {
                    Label("Save", systemImage: "tray.and.arrow.down.fill")
                }
                .disabled(viewModel.classificationResult == nil)
                .accessibilityLabel("Save classification to history")
            }
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(
                image: $viewModel.selectedImage,
                isPresented: $viewModel.showImagePicker,
                sourceType: viewModel.imageSourceType,
                onDismiss: {
                    // Optional: auto-classify after selection
                }
            )
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.selectedImage)
        .animation(.easeInOut, value: viewModel.classificationResult)
    }

    // MARK: - Subviews

    private var imagePreview: some View {
        Group {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(radius: 10)
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityLabel("Selected image for classification")
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(.secondary)
                    VStack(spacing: 8) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 40))
                        Text("Take a photo or choose from library")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                .frame(height: 240)
                .accessibilityLabel("No image selected")
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.checkCameraPermission()
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isClassifying)
                .accessibilityLabel("Take a new photo")

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.checkPhotoLibraryPermission()
                } label: {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isClassifying)
                .accessibilityLabel("Choose a photo from library")
            }

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                Task { await viewModel.classifySelectedImage() }
            } label: {
                HStack {
                    if viewModel.isClassifying {
                        ProgressView()
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(viewModel.isClassifying ? "Classifying..." : "Classify Image")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.selectedImage == nil || viewModel.isClassifying)
            .accessibilityLabel("Run image classification")

            Button(role: .destructive) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                viewModel.reset()
            } label: {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .accessibilityLabel("Reset current image and result")
        }
    }
}

#Preview {
    NavigationStack {
        CameraView()
    }
}
