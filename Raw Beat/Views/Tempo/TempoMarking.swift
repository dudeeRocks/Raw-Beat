//
//  TempoName.swift
//  Metronome
//
//  Created by David Katsman on 20/02/2024.
//

import SwiftUI

struct TempoMarking: View {
    
    @EnvironmentObject var metronome: Metronome
    @Binding var sharedData: SharedData
    
    private var opacity: Double {
        sharedData.overlayState == .none ? 1.0 : 0.0
    }
    
    
    var body: some View {
        if sharedData.didMeasureScrollItem {
            Text(sharedData.tempoName)
                .font(.system(size: 24, weight: .medium, design: .serif))
                .italic()
                .kerning(5.0)
                .foregroundStyle(.secondary)
                .opacity(opacity)
                .offset(x: 0, y: sharedData.getHintOffset())
                .onAppear {
                    sharedData.setTempoName(to: metronome.tempo)
                }
        }
    }
}
