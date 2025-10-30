import SwiftUI

struct WelcomeAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        Text("Hello! 👋")
            .font(.system(size: 72, weight: .bold))
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    rotation = 5
                }
            }
    }
}
