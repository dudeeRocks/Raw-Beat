//  Abstract: This is a background layer that responds to taps to set tempo.

import SwiftUI

struct TouchVisualizer: View {
    @ObservedObject var model: TouchPaticleSystem
    @Binding var sharedData: SharedData
    
    // MARK: - Properties
    
    @Binding var isLongPress: Bool
    
    // MARK: - Body
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let currentTime: Double = CACurrentMediaTime()
                
                model.update(at: currentTime)
                
                if isLongPress {
                    model.createPulse(time: currentTime, location: sharedData.safelyUnwrap(position: .tempoText))
                }
                
                resolveSymbols(for: model.taps, inContext: context)
                resolveSymbols(for: model.pulses, inContext: context)
            } symbols: {
                let tapSize: CGFloat = sharedData.safelyUnwrap(size: .playButton) / 2
                let pulseSize: CGFloat = sharedData.safelyUnwrap(size: .playButton) * 2.5
                
                // MARK: Tap particles
                ForEach(model.taps, id: \.id) { tap in
                    ParticleView(particle: tap, size: tapSize)
                }
                // MARK: LongPress particles
                ForEach(model.pulses, id: \.id) { pulse in
                    ParticleView(particle: pulse, size: pulseSize)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func resolveSymbols(for particles: [Particle], inContext context: GraphicsContext) {
        for particle in particles {
            
            var location: CGPoint {
                switch particle {
                case let tap as Tap:
                    return tap.location
                case is Pulse:
                    return sharedData.safelyUnwrap(position: .tempoText)
                default:
                    Log.sharedInstance.log(message: "Unknown particle. Returning CGPoint.zero.")
                    return .zero
                }
            }
            
            var particleContext = context
            
            if let resolvedSymbol = particleContext.resolveSymbol(id: particle.id) {
                if particle is Pulse {
                    particleContext.blendMode = .screen
                }
                particleContext.draw(resolvedSymbol, at: location)
            }
        }
    }
}
