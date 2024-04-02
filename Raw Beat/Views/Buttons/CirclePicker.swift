// Abstract: custom picker for sound and time signature selection.

import SwiftUI

struct CirclePicker: View {
    
    // MARK: Properties
    
    @EnvironmentObject var metronome: Metronome
    @Binding var sharedData: SharedData
    
    let pickerRole: SharedData.PickerState
    
    @AccessibilityFocusState private var isAccessibilityFocusOn: Bool
    
    // MARK: - Computed Properties
    
    private var isOpen: Bool {
        sharedData.pickerState == pickerRole
    }
    
    private var pickerOverlayState: SharedData.OverlayState {
        switch pickerRole {
        case .sound:
            return .soundPicker
        default:
            return .timePicker
        }
    }
    
    private var opacity: Double {
        if pickerRole == .sound {
            sharedData.overlayState == .timePicker ? 0.0 : 1.0
        } else {
            sharedData.overlayState == .soundPicker ? 0.0 : 1.0
        }
    }
    
    private var closeButtonSymbol: Image {
        if isOpen {
            return Image(systemName: "xmark")
        } else {
            if pickerRole == .sound {
                return Image(metronome.sound.symbol)
            } else {
                return Image(metronome.timeSignature.symbol)
            }
        }
    }
    
    private var closeButtonAccessibilityLabel: String {
        if isOpen {
            return String(localized: "Close picker", comment: "Picker's close button accessibility label")
        } else {
            if pickerRole == .sound {
                return String(localized: "Sound", comment: "Picker's close button accessibility label")
            } else {
                return String(localized: "Time signature", comment: "Picker's close button accessibility label")
            }
        }
    }
    
    private var closeButtonAccessibilityValue: String {
        if isOpen {
            return ""
        } else {
            let relevantLabel: String = pickerRole == .sound ? metronome.sound.accessibilityLabel : metronome.timeSignature.accessibilityLabel
            
            return String(localized: "\(relevantLabel) is selected", comment: "Part of accessibility label on picker buttons. Tells users what sound/time is selected.")
        }
    }
    
    private var closeButtonAccessibilityIdentifier: String {
        if pickerRole == .sound {
            return ViewIdentifiers.soundPicker.rawValue
        } else {
            return ViewIdentifiers.timePicker.rawValue
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if pickerRole == .sound {
                ZStack {
                    ForEach(Sound.allCases) { sound in
                        CircleToggle(
                            isOn: Binding(
                                get: { metronome.sound == sound },
                                set: { _ in metronome.sound = sound }),
                            isOutlined: true,
                            label: {
                                Image(sound.symbol)
                                    .symbolEffect(.bounce, options: .repeating, isActive: metronome.isPlaying && metronome.sound == sound)
                            })
                        .modifier(Modifiers.MenuTransition(for: sound.animationProperties, state: isOpen))
                    }
                }
                .accessibilityRepresentation {
                    if isOpen {
                        Picker(selection: Binding(get: {
                            metronome.sound
                        }, set: { newValue in
                            metronome.sound = newValue
                        })) {
                            ForEach(Sound.allCases) { sound in
                                Text(sound.accessibilityLabel).tag(sound)
                            }
                        } label: {
                            Text("Sound Picker", comment: "Accesibility label for sound picker.")
                        }
                        .accessibilityFocused($isAccessibilityFocusOn)
                    }
                }
            }
            
            if pickerRole == .timeSignature {
                ZStack {
                    ForEach(TimeSignature.allCases) { timeSignature in
                        CircleToggle(
                            isOn: Binding(
                                get: { metronome.timeSignature == timeSignature },
                                set: { _ in metronome.timeSignature = timeSignature }),
                            isOutlined: true,
                            label: {
                                Image(timeSignature.symbol)
                                    .symbolEffect(.bounce, options: .repeating, isActive: metronome.isPlaying && metronome.timeSignature == timeSignature)
                            })
                        .modifier(Modifiers.MenuTransition(for: timeSignature.animationProperties, state: isOpen))
                    }
                }
                .accessibilityRepresentation {
                    if isOpen {
                        Picker(selection: Binding(get: {
                            metronome.timeSignature
                        }, set: { newValue in
                            metronome.timeSignature = newValue
                        })) {
                            ForEach(TimeSignature.allCases) { timeSignature in
                                Text(timeSignature.accessibilityLabel).tag(timeSignature)
                            }
                        } label: {
                            Text("Time Signature Picker", comment: "Accesibility label for time signature picker.")
                        }
                        .accessibilityFocused($isAccessibilityFocusOn)
                    }
                }
            }
            
            Button {
                toggleMenu()
            } label: {
                SymbolContainer(frame: 24.0) {
                    closeButtonSymbol
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .accessibilitySortPriority(isOpen ? -1 : 0)
            .accessibilityLabel(closeButtonAccessibilityLabel)
            .accessibilityValue(closeButtonAccessibilityValue)
            .accessibilityIdentifier(closeButtonAccessibilityIdentifier)
            .buttonStyle(CircleButtonStyleForToggle(isPressed: isOpen, isOutlined: false))
            .getPosition(for: pickerRole == .sound ? .soundPicker : .timePicker, sharedData: $sharedData)
        }
        .opacity(opacity)
    }
    
    // MARK: - Methods
    
    private func toggleMenu() {
        if sharedData.overlayState == pickerOverlayState {
            isAccessibilityFocusOn = false
            withAnimation(Animations.menuClose) {
                sharedData.setPickerState(to: .none)
            }
            withAnimation(Animations.menuClose.delay(Animations.DurationPreset.min.value)) {
                sharedData.setOverlayState(to: .none)
            }
        } else {
            isAccessibilityFocusOn = true
            withAnimation(Animations.menuOpen) {
                sharedData.setOverlayState(to: pickerOverlayState)
                sharedData.setHint(to: .none)
            }
            withAnimation(Animations.menuOpen.delay(Animations.DurationPreset.min.value)) {
                sharedData.setPickerState(to: pickerRole)
            }
        }
    }
}


extension BounceSymbolEffect: IndefiniteSymbolEffect { }
