import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var titleScale: CGFloat = 0.2
    @State private var titleOpacity: Double = 0
    @State private var starsVisible = false
    @State private var gradientAngle: Double = 0
    @State private var bounceOffset: CGFloat = 0

    private let starColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    var body: some View {
        ZStack {
            // Animated rainbow background
            LinearGradient(
                colors: [
                    Color(hex: "#FF6B6B"),
                    Color(hex: "#FFA07A"),
                    Color(hex: "#FFD700"),
                    Color(hex: "#98FB98"),
                    Color(hex: "#87CEEB"),
                    Color(hex: "#DDA0DD")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Floating stars background
            if starsVisible {
                ForEach(0..<25, id: \.self) { i in
                    FloatingStarView(
                        color: starColors[i % starColors.count],
                        size: CGFloat.random(in: 20...50),
                        startX: CGFloat.random(in: 20...380),
                        startY: CGFloat.random(in: 50...700),
                        delay: Double(i) * 0.15
                    )
                }
            }

            // Clouds
            CloudView(x: 60, y: 80, scale: 0.8, delay: 0)
            CloudView(x: 320, y: 140, scale: 1.0, delay: 0.5)
            CloudView(x: 180, y: 60, scale: 0.6, delay: 1.0)

            VStack(spacing: 30) {
                // App title
                VStack(spacing: 8) {
                    Text("마법의")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)

                    Text("색칠나라")
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                        .offset(y: bounceOffset)

                    Text("Magic Coloring Kingdom")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

                // Character emoji display
                HStack(spacing: 20) {
                    Text("👑").font(.system(size: 45))
                        .offset(y: starsVisible ? -8 : 0)
                        .animation(.easeInOut(duration: 0.8).repeatForever().delay(0.1), value: starsVisible)

                    Text("🎨").font(.system(size: 55))
                        .offset(y: starsVisible ? 8 : 0)
                        .animation(.easeInOut(duration: 0.8).repeatForever().delay(0.3), value: starsVisible)

                    Text("✨").font(.system(size: 45))
                        .offset(y: starsVisible ? -8 : 0)
                        .animation(.easeInOut(duration: 0.8).repeatForever().delay(0.5), value: starsVisible)
                }
                .opacity(titleOpacity)

                // Start button
                Button {
                    SoundService.shared.play(.pageSelect)
                    appState.navigate(to: .home)
                } label: {
                    Text("시작하기! 🌟")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "#FF6B6B"))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .opacity(titleOpacity)
                .scaleEffect(starsVisible ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 1.0).repeatForever(), value: starsVisible)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.55)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                starsVisible = true
            }
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                bounceOffset = -8
            }
            // Auto advance after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                appState.navigate(to: .home)
            }
        }
    }
}

struct FloatingStarView: View {
    let color: Color
    let size: CGFloat
    let startX: CGFloat
    let startY: CGFloat
    let delay: Double

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0

    var body: some View {
        Image(systemName: ["star.fill", "heart.fill", "circle.fill", "diamond.fill"].randomElement()!)
            .font(.system(size: size))
            .foregroundColor(color.opacity(0.7))
            .rotationEffect(.degrees(rotation))
            .offset(x: startX - 200, y: startY - 300 + offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever().delay(delay)) {
                    offsetY = -60
                    opacity = 0.8
                    rotation = 360
                }
            }
    }
}

struct CloudView: View {
    let x: CGFloat
    let y: CGFloat
    let scale: CGFloat
    let delay: Double
    @State private var offsetX: CGFloat = -50

    var body: some View {
        Text("☁️")
            .font(.system(size: 60 * scale))
            .offset(x: x - 200 + offsetX, y: y - 300)
            .opacity(0.6)
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: true).delay(delay)) {
                    offsetX = 50
                }
            }
    }
}
