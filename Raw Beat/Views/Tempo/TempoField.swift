// Abstract: Tempo Field

import SwiftUI

struct TempoField: View {
    
    // MARK: Properties
    @EnvironmentObject var metronome: Metronome
    @Binding var sharedData: SharedData
    @FocusState var isFocused: Bool
    @State private var prompt: String = ""
    @State private var text: String = ""
    private let characterLimit: Int = 3
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if sharedData.isFieldShaking {
                Color.clear
                    .onAppear {
                        stopShakingFieldAfter(seconds: 0.1)
                    }
            }
            TextField(prompt, text: $text)
                .modifier(Modifiers.TempoText())
                .keyboardType(.numberPad)
                .focused($isFocused)
                .offset(x: sharedData.isFieldShaking ? -20 : 0)
                .animation(.spring(response: 0.1, dampingFraction: 0.1), value: sharedData.isFieldShaking)
                .onAppear {
                    prepareTextField()
                }
                .onChange(of: text) { oldValue, newValue in
                    enforceCharacterLimit(oldValue, newValue)
                    convertTextToTempo(text)
                }
                .accessibilityLabel("Tempo input field")
                .accessibilityIdentifier(ViewIdentifiers.tempoField.rawValue)
            ErrorMessage(sharedData: $sharedData)
        }
    }
    
    // MARK: - Methods
    
    private func enforceCharacterLimit(_ oldValue: String, _ newValue: String) {
        if newValue.count > characterLimit {
            text = oldValue
        }
    }
    
    private func convertTextToTempo(_ string: String) {
        if let newValue = Int(string) {
            sharedData.newTempo = newValue
        } else {
            sharedData.newTempo = sharedData.oldTempo
        }
    }
    
    private func prepareTextField() {
        sharedData.oldTempo = metronome.tempo
        prompt = String(metronome.tempo)
        text = ""
        isFocused = true
    }
    
    private func stopShakingFieldAfter(seconds deadline: TimeInterval) {
        Task(priority: .userInitiated) {
            try await Task.sleep(until: .now + .seconds(deadline))
            sharedData.shakeTempoField(false)
        }
    }
}
