import Foundation
import SwiftUI
import UIKit
import Combine

@MainActor
final class CameraViewModel: ObservableObject {
    // Dependencies
    private let classifier: ImageClassifier
    private let coreDataManager: CoreDataManager

    // MARK: - Published State

    @Published var selectedImage: UIImage?
    @Published var classificationResult: String?
    @Published var confidence: Double?
    @Published var isClassifying: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var imageSourceType: UIImagePickerController.SourceType = .camera
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    init(classifier: ImageClassifier = .shared,
         coreDataManager: CoreDataManager = CoreDataManager()) {
        self.classifier = classifier
        self.coreDataManager = coreDataManager
    }

    // MARK: - Actions

    func classifySelectedImage() async {
        guard let image = selectedImage else {
            presentError("No image selected. Please capture or pick a photo first.")
            return
        }

        isClassifying = true
        defer { isClassifying = false }

        do {
            let result = try await classifier.classifyImage(image: image)
            classificationResult = result.classification
            confidence = result.confidence
        } catch let error as ImageClassifier.ClassificationError {
            presentError(error.localizedDescription)
        } catch {
            presentError("An unexpected error occurred while classifying the image.")
        }
    }

    func saveToHistory() async {
        guard let image = selectedImage else {
            presentError("Nothing to save. Please select an image first.")
            return
        }
        guard let classification = classificationResult,
              let confidence = confidence else {
            presentError("Please classify the image before saving.")
            return
        }

        let imageName = UUID().uuidString
        let imageData = image.jpegData(compressionQuality: 0.9)

        do {
            _ = try await coreDataManager.saveClassifiedPhoto(
                imageData: imageData,
                imageName: imageName,
                classification: classification,
                confidence: confidence,
                timestamp: Date()
            )
        } catch let error as PhotoSenseError {
            presentError("Failed to save classification: \(error.localizedDescription)")
        } catch {
            presentError("An unexpected error occurred while saving the result.")
        }
    }

    func reset() {
        selectedImage = nil
        classificationResult = nil
        confidence = nil
        errorMessage = nil
        showError = false
    }

    func checkCameraPermission() {
        ImagePicker.checkCameraPermission { [weak self] granted in
            guard let self else { return }
            if granted {
                self.imageSourceType = .camera
                self.showImagePicker = true
            } else {
                self.presentError("Camera access is denied. Please enable it in Settings to take photos.")
            }
        }
    }

    func checkPhotoLibraryPermission() {
        ImagePicker.checkPhotoLibraryPermission { [weak self] granted in
            guard let self else { return }
            if granted {
                self.imageSourceType = .photoLibrary
                self.showImagePicker = true
            } else {
                self.presentError("Photo library access is denied. Please enable it in Settings to pick photos.")
            }
        }
    }

    // MARK: - Private

    private func presentError(_ message: String) {
        errorMessage = message
        showError = true
    }
}
