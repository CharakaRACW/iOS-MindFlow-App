import SwiftUI

struct LaunchScreenView: View {
    @State private var animate: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [DesignSystem.Colors.psBlue, DesignSystem.Colors.psPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 96, height: 96)
                        .scaleEffect(animate ? 1.0 : 0.7)
                        .opacity(animate ? 1.0 : 0.6)

                    Image(systemName: "camera.metering.center.weighted")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                        .font(.system(size: 40, weight: .semibold))
                }

                VStack(spacing: 4) {
                    Text("PhotoSense")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                    Text("Discover what's in your photos")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding()
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                    animate = true
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
