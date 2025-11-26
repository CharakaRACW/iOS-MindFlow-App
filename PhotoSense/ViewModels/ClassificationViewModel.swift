import Foundation
import SwiftUI
import CoreData
import Combine

@MainActor
final class ClassificationViewModel: ObservableObject {
    // Dependencies
    private let coreDataManager: CoreDataManager
    private let imageClassifier: ImageClassifier

    // Published state
    @Published var latestClassification: String?
    @Published var latestConfidence: Double?
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?

    init(coreDataManager: CoreDataManager, imageClassifier: ImageClassifier) {
        self.coreDataManager = coreDataManager
        self.imageClassifier = imageClassifier
    }

    // TODO: Add method to handle image capture / selection and trigger classification
    // TODO: On successful classification, persist a new ClassifiedPhoto via CoreDataManager
}
