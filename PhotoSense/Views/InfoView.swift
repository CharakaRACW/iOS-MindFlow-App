import SwiftUI

struct InfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to use PhotoSense")
                    .font(DesignSystem.Typography.title)

                Group {
                    Text("1. Classify a new photo")
                        .font(DesignSystem.Typography.headline)
                    Text("Open the Camera tab to take a new photo or choose one from your library. Tap \"Classify Image\" to run the on-device model and see the result.")
                        .font(DesignSystem.Typography.body)

                    Text("2. Review your history")
                        .font(DesignSystem.Typography.headline)
                    Text("The History tab shows your previous classifications grouped by date. Tap any row to see more details, share, or delete the entry.")
                        .font(DesignSystem.Typography.body)

                    Text("3. Explore the dashboard")
                        .font(DesignSystem.Typography.headline)
                    Text("The Home tab summarizes how you have been using PhotoSense: total photos, common labels, confidence trends, and quick shortcuts.")
                        .font(DesignSystem.Typography.body)
                }

                Group {
                    Text("Tips for best results")
                        .font(DesignSystem.Typography.headline)
                    Text("• Use good lighting and avoid motion blur.\n• Fill the frame with the main subject.\n• Try different angles if the result looks uncertain.\n• Keep the subject in focus.")
                        .font(DesignSystem.Typography.body)
                }

                Group {
                    Text("Troubleshooting")
                        .font(DesignSystem.Typography.headline)
                    Text("If classification fails:")
                        .font(DesignSystem.Typography.body)
                    Text("• Check that camera and photo permissions are enabled in Settings.\n• Ensure the device is not in Low Power Mode if performance is degraded.\n• Try a simpler background or clearer subject.")
                        .font(DesignSystem.Typography.body)
                    Text("If the app crashes or behaves unexpectedly, try force-closing and reopening. Persistent issues can often be resolved by reinstalling the app.")
                        .font(DesignSystem.Typography.body)
                }
            }
            .padding()
        }
        .navigationTitle("Info & Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        InfoView()
    }
}
