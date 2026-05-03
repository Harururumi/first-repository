import SwiftUI

struct CelebrationView: View {
    @Binding var isShowing: Bool
    let onSave: () -> Void

    @State private var particles: [Particle] = []
    @State private var titleScale: CGFloat = 0.1
    @State private var titleOpacity: Double = 0

    private let particleColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        Color(hex: "#FF6B9D"), Color(hex: "#FFD700")
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Confetti particles
            ForEach(particles) { p in
                ParticleView(particle: p)
            }

            // Main celebration card
            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 72))

                VStack(spacing: 8) {
                    Text("훌륭해요!")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "#FFD700"))
                        .shadow(color: .orange.opacity(0.6), radius: 8, x: 0, y: 2)

                    Text("Wonderful job!")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("그림을 완성했어요! ⭐")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }

                HStack(spacing: 16) {
                    Button {
                        dismiss()
                    } label: {
                        Text("계속 색칠하기")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "#FF6B6B"))
                            .padding(.horizontal, 22)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }

                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Text("저장하고 나가기 💾")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 14)
                            .background(Color(hex: "#34C759"))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#7B2FF7"), Color(hex: "#F107A3")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            .scaleEffect(titleScale)
            .opacity(titleOpacity)
            .padding(24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            spawnParticles()
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            isShowing = false
        }
    }

    private func spawnParticles() {
        particles = (0..<60).map { i in
            Particle(
                color: particleColors[i % particleColors.count],
                size: CGFloat.random(in: 8...22),
                startX: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                delay: Double.random(in: 0...1.2),
                shape: i % 3
            )
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let startX: CGFloat
    let delay: Double
    let shape: Int
}

struct ParticleView: View {
    let particle: Particle
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0

    var body: some View {
        Group {
            switch particle.shape {
            case 0:
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
            case 1:
                RoundedRectangle(cornerRadius: 3)
                    .fill(particle.color)
                    .frame(width: particle.size * 0.6, height: particle.size)
            default:
                Image(systemName: "star.fill")
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
            }
        }
        .rotationEffect(.degrees(rotation))
        .position(x: particle.startX, y: UIScreen.main.bounds.height + offsetY)
        .opacity(opacity)
        .onAppear {
            withAnimation(
                .easeOut(duration: Double.random(in: 1.5...2.8))
                .delay(particle.delay)
                .repeatForever(autoreverses: false)
            ) {
                offsetY = -(UIScreen.main.bounds.height + 200)
                opacity = 1
                rotation = Double.random(in: -360...360)
            }
        }
    }
}
