import SwiftUI
import CoreData

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        fetchRequest: ClassifiedPhoto.fetchAllSortedByDateRequest(),
        animation: .default
    ) private var photos: FetchedResults<ClassifiedPhoto>

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                CameraView()
            }
            .tabItem {
                Label("Camera", systemImage: "camera.fill")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }
            .badge(photos.count)
        }
        .tint(DesignSystem.Colors.primaryStart)
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
