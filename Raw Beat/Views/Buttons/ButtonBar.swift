// Abstract: Main button bar that transitions between main and submit buttons

import SwiftUI

struct ButtonBar: View {
    @EnvironmentObject var metronome: Metronome
    @Binding var sharedData: SharedData
    
    var submit: () -> Void
    var dismiss: () -> Void
    
    private let padding: EdgeInsets = .init(top: 20, leading: 32, bottom: 40, trailing: 32)
    
    private var isTempoFieldInFocus: Bool {
        return sharedData.overlayState == .tempoFieldEditing
    }
    
    private var geometryProxy: GeometryProxy {
        return sharedData.mainGeometryProxy
    }
    
    var body: some View {
        if sharedData.didSetMainGeometryProxy {
            ZStack {
                // MARK: Main buttons group
                HStack(alignment: .center) {
                    CirclePicker(sharedData: $sharedData, pickerRole: .sound)
                    Spacer()
                    PlayButton(sharedData: $sharedData)
                        .getPosition(for: .playButton, sharedData: $sharedData)
                    Spacer()
                    CirclePicker(sharedData: $sharedData, pickerRole: .timeSignature)
                }
                .padding(padding)
                .offset(y: isTempoFieldInFocus ? 300 : 0.0)
                .opacity(isTempoFieldInFocus ? 0.0 : 1.0)
                
                // MARK: Submit buttons group
                HStack {
                    CircleButton(action: dismiss, label: { Image(systemName: "xmark") })
                        .accessibilityLabel("Cancel")
                        .accessibilityIdentifier(ViewIdentifiers.dismissButton.rawValue)
                    Spacer()
                    CircleButton(action: submit, label: { Image(systemName: "checkmark").accessibilityHidden(true) })
                        .accessibilityLabel("Set tempo")
                        .accessibilityIdentifier(ViewIdentifiers.submitButton.rawValue)
                }
                .padding(padding)
                .offset(y: isTempoFieldInFocus ? 0.0 : 300.0)
                .opacity(isTempoFieldInFocus ? 1.0 : 0.0)
            }
        }
    }
}
