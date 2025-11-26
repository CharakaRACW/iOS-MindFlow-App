import SwiftUI

struct SplashView: View {
    @State private var animate: Bool = false

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.primaryGradient)
                        .frame(width: 96, height: 96)
                        .scaleEffect(animate ? 1.0 : 0.6)
                        .opacity(animate ? 1.0 : 0.4)

                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(.white)
                        .imageScale(.large)
                        .font(.system(size: 32, weight: .bold))
                }
                .shadow(color: DesignSystem.Colors.shadowStrong, radius: 20, x: 0, y: 12)

                Text("PhotoSense")
                    .font(DesignSystem.Typography.title)

                Text("On-device AI photo insights")
                    .font(DesignSystem.Typography.body)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
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
    SplashView()
}
