// Abstract: the view that is used for generating taps.

import SwiftUI

struct ParticleView: View {
    
    private let particle: Particle
    private let size: CGFloat
    private let scale: Double
    private let opacity: Double
    private let tag: String
    private let color: Color
    
    var body: some View {
        if particle is Tap {
            createTapView()
        } else if particle is Pulse {
            createPulseView()
        } else {
            createBeatView()
        }
    }
    
    // MARK:  - Initializer
    
    init(particle: Particle, size: CGFloat) {
        self.particle = particle
        self.size = size
        
        scale = particle.scale
        opacity = particle.opacity
        tag = particle.id
        
        color = {
            switch particle {
            case is Beat:
                return .accentColor
            case is Tap:
                return .primaryColor
            case is Pulse:
                return .primaryColor
            default:
                return .blue
            }
        }()
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder private func createTapView() -> some View {
        ZStack {
            Circle()
                .strokeBorder(color, lineWidth: 1, antialiased: true)
                .frame(width: size)
                .scaleEffect(scale, anchor: .center)
                .opacity(opacity)
            Circle()
                .strokeBorder(color, lineWidth: 1, antialiased: true)
                .frame(width: size - 10)
                .scaleEffect(scale, anchor: .center)
                .opacity(opacity / 2)
            Circle()
                .strokeBorder(color, lineWidth: 1, antialiased: true)
                .frame(width: size - 20)
                .scaleEffect(scale, anchor: .center)
                .opacity(opacity / 3)
        }
        .tag(tag)
    }
    
    @ViewBuilder private func createPulseView() -> some View {
        Circle()
            .strokeBorder(color, lineWidth: 1, antialiased: true)
            .frame(width: size)
            .scaleEffect(scale, anchor: .center)
            .opacity(opacity)
            .tag(tag)
    }
    
    @ViewBuilder private func createBeatView() -> some View {
        Circle()
            .strokeBorder(color, lineWidth: 1, antialiased: true)
            .frame(width: size)
            .scaleEffect(scale, anchor: .center)
            .opacity(opacity)
            .tag(tag)
    }
    
}
