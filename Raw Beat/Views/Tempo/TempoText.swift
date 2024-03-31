// Abstract: The view that represents current tempo value and

import SwiftUI

struct TempoText: View {
    
    // MARK: Properties
    @EnvironmentObject var metronome: Metronome
    @Binding var sharedData: SharedData
    @Binding var isPressed: Bool
    
    private var text: String {
        return "\(sharedData.newTempo)"
    }
    
    private var isEditing: Bool {
        return sharedData.overlayState == .tempoFieldEditing
    }
    
    private var isAnyPickerOpen: Bool {
        return sharedData.overlayState == .timePicker || sharedData.overlayState == .soundPicker
    }
    
    private var opacity: Double {
        if isEditing {
            return 0.0
        } else if isAnyPickerOpen {
            return 0.2
        } else {
            return 1.0
        }
    }
    
    var body: some View {
        if sharedData.didSetMainGeometryProxy {
            ZStack {
                Circle()
                    .fill(Color.gradientStartColor)
                    .frame(width: 100)
                    .blur(radius: 15)
                    .opacity(isPressed ? 0.0 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: isPressed)
                Text(text)
                    .accessibilityLabel("Current tempo")
                    .accessibilityValue(text + " beats per minute")
                    .accessibilityHint("Triple tap to edit the value.")
                    .accessibilityHidden(isAnyPickerOpen)
                    .accessibilityIdentifier("tempoText")
                    .modifier(Modifiers.TempoText())
                    .getPosition(for: .tempoText, sharedData: $sharedData)
                    .shadow(color: Color.gradientStartColor.opacity(isPressed ? 0.0 : 1.0),
                            radius: 1.0,
                            x: 0.0,
                            y: 1.0)
                    .onAppear {
                        sharedData.newTempo = metronome.tempo
                    }
            }
            .opacity(opacity)
        }
    }
}
