import Foundation
import CoreData

enum PhotoSenseError: Error {
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case clearFailed(underlying: Error)
    case objectNotFound
}

final class CoreDataManager {
    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    // MARK: - Public API

    func saveClassifiedPhoto(
        imageData: Data?,
        imageName: String,
        classification: String,
        confidence: Double,
        timestamp: Date = Date()
    ) async throws -> ClassifiedPhoto {
        let objectID: NSManagedObjectID = try await performInBackground { context in
            let photo = ClassifiedPhoto(context: context)
            photo.id = UUID()
            photo.imageName = imageName
            photo.classification = classification
            photo.confidence = confidence
            photo.timestamp = timestamp
            photo.imageData = imageData

            do {
                try context.save()
                return photo.objectID
            } catch {
                context.rollback()
                throw PhotoSenseError.saveFailed(underlying: error)
            }
        }

        return try await viewContext.perform { [viewContext] in
            guard let object = try? viewContext.existingObject(with: objectID) as? ClassifiedPhoto else {
                throw PhotoSenseError.objectNotFound
            }
            return object
        }
    }

    func fetchAllPhotosSortedByDate() async throws -> [ClassifiedPhoto] {
        let request = ClassifiedPhoto.fetchAllSortedByDateRequest()

        return try await viewContext.perform { [viewContext] in
            do {
                return try viewContext.fetch(request)
            } catch {
                throw PhotoSenseError.fetchFailed(underlying: error)
            }
        }
    }

    func deletePhoto(withID id: UUID) async throws {
        try await performInBackground { context in
            let request = ClassifiedPhoto.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            do {
                let results = try context.fetch(request)
                guard let photo = results.first else {
                    throw PhotoSenseError.objectNotFound
                }

                context.delete(photo)
                try context.save()
            } catch let error as PhotoSenseError {
                throw error
            } catch {
                context.rollback()
                throw PhotoSenseError.deleteFailed(underlying: error)
            }
        }
    }

    func clearAllPhotos() async throws {
        try await performInBackground { context in
            let request = ClassifiedPhoto.fetchRequest()

            do {
                let results = try context.fetch(request)
                for object in results {
                    context.delete(object)
                }
                try context.save()
            } catch {
                context.rollback()
                throw PhotoSenseError.clearFailed(underlying: error)
            }
        }
    }

    // MARK: - Helpers

    private func performInBackground<T>(_ work: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        let context = backgroundContext

        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                do {
                    let result = try work(context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
