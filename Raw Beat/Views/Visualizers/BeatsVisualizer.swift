// Abstract: a view to generate beat objects on screen.

import SwiftUI

struct BeatsVisualizer: View {
    @EnvironmentObject var metronome: Metronome
    @ObservedObject var model: BeatsParticleSystem
    @Binding var sharedData: SharedData
    
    private var isPlaying: Bool { metronome.isPlaying }
    
    // MARK: - Body
    
    var body: some View {
        if isPlaying {
            TimelineView(.animation) { timeline in
                Canvas { context, _ in
                    let currentTime: Double = CACurrentMediaTime()
                    
                    model.update(at: currentTime)
                    resolveSymbols(for: model.beats, inContext: context)
                    
                } symbols: {
                    let beatSize: CGFloat = getBeatSize()
                    
                    ForEach(model.beats, id: \.id) { beat in
                        ParticleView(particle: beat, size: beatSize)
                    }
                }
            }
            .ignoresSafeArea()
            .onDisappear {
                model.beats = []
            }
        }
    }
    
    // MARK: - Methods
    
    private func resolveSymbols(for beats: [Beat], inContext context: GraphicsContext) {
        for beat in beats {
            
            let location: CGPoint = getRelevantPlayAnimationPosition()
            
            let beatContext = context
            
            if let resolvedSymbol = beatContext.resolveSymbol(id: beat.id) {
                beatContext.draw(resolvedSymbol, at: location)
            }
        }
    }
    
    private func getBeatSize() -> CGFloat {
        let pickerState = sharedData.pickerState
        
        switch pickerState {
        case .none:
            return sharedData.safelyUnwrap(size: .playButton)
        default:
            return sharedData.safelyUnwrap(size: .timePicker)
        }
    }
    
    private func getRelevantPlayAnimationPosition() -> CGPoint {
        var result: CGPoint = .zero
        
        switch sharedData.pickerState {
        case .none:
            result = sharedData.safelyUnwrap(position: .playButton)
        case .sound:
            result = getPositionFor(sound: metronome.sound)
        case .timeSignature:
            result = getPositionFor(timeSignature: metronome.timeSignature)
        }
        
        return result
    }
    
    private func getPositionFor(sound: Sound) -> CGPoint {
        var result: CGPoint = .zero
        
        switch sound {
        case .tick:
            result = sharedData.safelyUnwrap(position: .soundTick)
        case .hihat:
            result = sharedData.safelyUnwrap(position: .soundHihat)
        case .kick:
            result = sharedData.safelyUnwrap(position: .soundKick)
        }
        
        return result
    }
    
    private func getPositionFor(timeSignature: TimeSignature) -> CGPoint {
        var result: CGPoint = .zero
        
        switch timeSignature {
        case .threeFourth:
            result = sharedData.safelyUnwrap(position: .timeThreeFourth)
        case .fourFourth:
            result = sharedData.safelyUnwrap(position: .timeFourFourth)
        case .sixEighths:
            result = sharedData.safelyUnwrap(position: .timeSixEighths)
        }
        
        return result
    }
}
