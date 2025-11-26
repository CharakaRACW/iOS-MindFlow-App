import Foundation
import CoreData
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    private let context: NSManagedObjectContext

    @Published private(set) var photos: [ClassifiedPhoto] = []

    init(context: NSManagedObjectContext) {
        self.context = context
        Task { await refresh() }
    }

    func refresh() async {
        let request = ClassifiedPhoto.fetchAllSortedByDateRequest()
        do {
            let result = try context.fetch(request)
            await MainActor.run {
                self.photos = result
            }
        } catch {
            await MainActor.run {
                self.photos = []
            }
        }
    }

    var totalPhotos: Int { photos.count }

    var mostCommonClassification: String? {
        guard !photos.isEmpty else { return nil }
        let counts = photos.reduce(into: [String: Int]()) { dict, photo in
            dict[photo.classification, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    var averageConfidence: Double? {
        guard !photos.isEmpty else { return nil }
        let sum = photos.reduce(0.0) { $0 + $1.confidence }
        return sum / Double(photos.count)
    }

    var photosToday: Int {
        let calendar = Calendar.current
        let timestamps = photos.compactMap { $0.timestamp }
        return timestamps.filter { calendar.isDateInToday($0) }.count
    }

    var recentPhotos: [ClassifiedPhoto] {
        Array(photos.prefix(5))
    }
}
