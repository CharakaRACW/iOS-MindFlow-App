import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        fetchRequest: ClassifiedPhoto.fetchAllSortedByDateRequest(),
        animation: .default
    )
    private var photos: FetchedResults<ClassifiedPhoto>

    @State private var searchText: String = ""

    private var filteredPhotos: [ClassifiedPhoto] {
        let all = Array(photos)
        guard !searchText.isEmpty else { return all }
        return all.filter { photo in
            (photo.classification ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    private var sectionedPhotos: [(title: String, items: [ClassifiedPhoto])] {
        let grouped = Dictionary(grouping: filteredPhotos) { (photo: ClassifiedPhoto) in
            (photo.timestamp ?? Date()).historySectionTitle()
        }

        let order = ["Today", "Yesterday", "This Week", "Earlier"]

        return grouped
            .map { (key, value) in
                let sortedItems = value.sorted { (lhs, rhs) in
                    let lDate = lhs.timestamp ?? .distantPast
                    let rDate = rhs.timestamp ?? .distantPast
                    return lDate > rDate
                }
                return (title: key, items: sortedItems)
            }
            .sorted { lhs, rhs in
                let lIndex = order.firstIndex(of: lhs.title) ?? order.count
                let rIndex = order.firstIndex(of: rhs.title) ?? order.count
                return lIndex < rIndex
            }
    }

    var body: some View {
        Group {
            if sectionedPhotos.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No history yet")
                        .font(.headline)
                    Text("Classify a photo to see it appear here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(sectionedPhotos, id: \.title) { section in
                        Section(section.title) {
                            ForEach(section.items) { photo in
                                NavigationLink {
                                    PhotoDetailView(photo: photo)
                                } label: {
                                    HistoryRowView(photo: photo)
                                }
                            }
                            .onDelete { indexSet in
                                delete(atOffsets: indexSet, in: section.items)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await refresh()
                }
            }
        }
        .navigationTitle("History")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search classifications")
        .animation(.default, value: sectionedPhotos.count)
    }

    private func delete(atOffsets offsets: IndexSet, in sectionItems: [ClassifiedPhoto]) {
        withAnimation {
            offsets.map { sectionItems[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // In a production app, surface this error to the user.
            }
        }
    }

    private func refresh() async {
        await MainActor.run {
            viewContext.refreshAllObjects()
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
