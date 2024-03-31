// Abstract: Main CTA in the UI. Starts/pauses metronome.

import SwiftUI

struct PlayButton: View {
    @EnvironmentObject private var metronome: Metronome
    @Binding var sharedData: SharedData
    
    // MARK: - Computed Properties
    
    private var opacity: Double {
        sharedData.overlayState == .soundPicker || sharedData.overlayState == .timePicker ? 0.0 : 1.0
    }
    
    private var symbol: String {
        metronome.isPlaying ? "stop.fill" : "play.fill"
    }
    
    // MARK: - Body
    
    var body: some View {
        Button {
            toggleMetronome()
        } label: {
            SymbolContainer(frame: 36.0) {
                Image(systemName: symbol)
                    .font(.system(size: 36))
                    .bold()
                    .contentTransition(.symbolEffect(.replace.downUp))
            }
        }
        .opacity(opacity)
        .buttonStyle(CircleButtonStyleForToggle(isPressed: metronome.isPlaying, isOutlined: false, size: .large))
    }
    
    // MARK: - Methods
    
    private func toggleMetronome() {
        showVolumeHintIfNeeded()
        metronome.isPlaying ? metronome.stop() : metronome.play()
    }
    
    private func showVolumeHintIfNeeded() {
        if !metronome.isPlaying && metronome.isVolumeOff {
            withAnimation(Animations.hint) {
                sharedData.setHint(to: .volumeOff)
            }
        }
    }
}
