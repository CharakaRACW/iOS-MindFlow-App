import Foundation
import CoreML
import Vision
import UIKit

/// A service responsible for running CoreML-based image classification
/// for the PhotoSense app using the Vision framework.
///
/// This implementation uses the MobileNetV2 CoreML model (which must be
/// included in the app bundle and expose a generated `MobileNetV2` class).
///
/// - It exposes a singleton `ImageClassifier.shared` for app-wide use.
/// - The main entry point is the async `classifyImage(image:)` method.
/// - The heavy Vision/CoreML work is dispatched off the main thread.
final class ImageClassifier {

    /// Result returned from a classification request.
    struct ClassificationResult {
        /// The identifier / label for the top prediction.
        let classification: String
        /// Confidence score as a value between 0.0 and 1.0.
        let confidence: Double

        /// Convenience formatted confidence string, e.g. "93.4%".
        var confidenceText: String {
            ImageClassifier.formattedConfidence(confidence)
        }
    }

    /// Errors that can occur during model loading or image classification.
    enum ClassificationError: Error {
        case modelLoadingFailed
        case imageProcessingFailed
        case classificationFailed
        case invalidImage

        /// A user-friendly error message describing the failure.
        var localizedDescription: String {
            switch self {
            case .modelLoadingFailed:
                return "The classification model could not be loaded. Please try again later."
            case .imageProcessingFailed:
                return "The image could not be processed for classification."
            case .classificationFailed:
                return "The image could not be classified. Please capture another photo."
            case .invalidImage:
                return "The captured image is invalid or corrupted. Please try again."
            }
        }
    }

    // MARK: - Singleton

    /// Shared singleton instance used throughout the app.
    static let shared = ImageClassifier()

    /// Underlying Vision model, lazily loaded from the MobileNetV2 CoreML model.
    ///
    /// The app is expected to include a MobileNetV2.mlmodel, which generates a
    /// `MobileNetV2` class at build time.
    private let coreMLModel: VNCoreMLModel? = {
        do {
            let configuration = MLModelConfiguration()
            let model = try MobileNetV2(configuration: configuration).model
            return try VNCoreMLModel(for: model)
        } catch {
            return nil
        }
    }()

    private init() {}

    // MARK: - Public API

    /// Classifies the given image asynchronously using the MobileNetV2 model.
    ///
    /// - Parameter image: Input `UIImage` to classify.
    /// - Returns: A `ClassificationResult` containing the top prediction.
    /// - Throws: `ClassificationError` when model loading, image processing,
    ///           or classification fails.
    func classifyImage(image: UIImage) async throws -> ClassificationResult {
        guard let cgImage = image.cgImage else {
            throw ClassificationError.invalidImage
        }

        guard let model = coreMLModel else {
            throw ClassificationError.modelLoadingFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            // Run Vision/CoreML on a background queue.
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNCoreMLRequest(model: model) { request, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let results = request.results as? [VNClassificationObservation],
                          let top = results.first else {
                        continuation.resume(throwing: ClassificationError.classificationFailed)
                        return
                    }

                    let result = ClassificationResult(
                        classification: top.identifier,
                        confidence: Double(top.confidence)
                    )
                    continuation.resume(returning: result)
                }

                // Configure request for best-accuracy, single result.
                request.imageCropAndScaleOption = .centerCrop

                // Use the image's orientation so results are correct.
                let orientation = CGImagePropertyOrientation(image.imageOrientation)
                let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])

                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: ClassificationError.imageProcessingFailed)
                }
            }
        }
    }

    // MARK: - Helpers

    /// Converts a `UIImage` into a `CVPixelBuffer` suitable for CoreML models
    /// that require pixel buffer input.
    ///
    /// - Parameters:
    ///   - image: The source `UIImage`.
    ///   - size: Target size for the pixel buffer.
    /// - Returns: A `CVPixelBuffer` or `nil` if conversion fails.
    static func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]

        var pixelBufferOptional: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs as CFDictionary,
            &pixelBufferOptional
        )

        guard status == kCVReturnSuccess, let pixelBuffer = pixelBufferOptional else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }

        guard let cgImage = image.cgImage else { return nil }

        context.clear(CGRect(origin: .zero, size: size))
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))

        return pixelBuffer
    }

    /// Formats a confidence value in the range 0.0...1.0 as a percentage string.
    ///
    /// - Parameter confidence: Confidence value between 0 and 1.
    /// - Returns: A string like "95.2%".
    static func formattedConfidence(_ confidence: Double) -> String {
        String(format: "%.1f%%", confidence * 100.0)
    }
}

// MARK: - Utilities

private extension CGImagePropertyOrientation {
    /// Initialize from `UIImage.Orientation` to correctly forward orientation
    /// information to Vision.
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
