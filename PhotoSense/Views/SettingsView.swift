import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var isClearing: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("About") {
                    HStack {
                        Text("App")
                        Spacer()
                        Text("PhotoSense")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Data") {
                    Button(role: .destructive) {
                        Task { await clearAllData() }
                    } label: {
                        if isClearing {
                            ProgressView()
                        } else {
                            Text("Clear all classified photos")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func clearAllData() async {
        guard !isClearing else { return }
        isClearing = true
        defer { isClearing = false }

        do {
            let request = ClassifiedPhoto.fetchRequest()
            let items = try viewContext.fetch(request)
            for item in items {
                viewContext.delete(item)
            }
            try viewContext.save()
        } catch {
            // In a production app, surface this error.
        }
    }
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
