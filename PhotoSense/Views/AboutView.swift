import SwiftUI

struct AboutView: View {
    var body: some View {
        Form {
            Section("PhotoSense") {
                Text("PhotoSense is your personal, on-device photo assistant. It uses Core ML to classify images without sending them to a server, keeping your memories private while still giving you AI-powered insights.")
                    .font(.body)
            }

            Section("Version") {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Developer") {
                HStack {
                    Text("Developed by")
                    Spacer()
                    Text("Your Name")
                        .foregroundStyle(.secondary)
                }

                if let url = URL(string: "https://github.com/your-github-username/PhotoSense") {
                    Link(destination: url) {
                        Label("View on GitHub", systemImage: "link")
                    }
                }
            }
        }
        .navigationTitle("About PhotoSense")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
