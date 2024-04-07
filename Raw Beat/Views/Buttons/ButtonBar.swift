// Abstract: Main button bar that transitions between main and submit buttons

import SwiftUI

struct ButtonBar: View {
    @EnvironmentObject var metronome: Metronome
    @Binding var sharedData: SharedData
    
    var submit: () -> Void
    var dismiss: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var padding: EdgeInsets {
        let top: CGFloat = 20.0, sides = 32.0, bottom = 40.0
        let factor: CGFloat = horizontalSizeClass == .compact ? 1.0 : 2.0
        return EdgeInsets(top: top,
                          leading: sides * factor,
                          bottom: bottom * factor,
                          trailing: sides * factor)
    }
    
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
                        .accessibilityLabel(String(localized: "Cancel", comment: "Accessibility label for button to cancel tempo input."))
                        .accessibilityIdentifier(ViewIdentifiers.dismissButton.rawValue)
                    Spacer()
                    CircleButton(action: submit, label: { Image(systemName: "checkmark").accessibilityHidden(true) })
                        .accessibilityLabel(String(localized: "Set tempo", comment: "Accessibility label for button submit tempo input."))
                        .accessibilityIdentifier(ViewIdentifiers.submitButton.rawValue)
                }
                .padding(padding)
                .offset(y: isTempoFieldInFocus ? 0.0 : 300.0)
                .opacity(isTempoFieldInFocus ? 1.0 : 0.0)
            }
        }
    }
}
