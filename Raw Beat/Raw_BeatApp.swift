//
//  Raw_BeatApp.swift
//  Raw Beat
//
//  Created by David Katsman on 31/03/2024.
//

import SwiftUI

@main
struct Raw_BeatApp: App {
    @StateObject private var metronome = Metronome()
    @StateObject private var hapticPlayer = HapticsPlayer()
    @StateObject private var touchParticleSystem = TouchPaticleSystem()
    @StateObject private var beatsParticleSystem = BeatsParticleSystem()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView(metronome: metronome,
                     hapticsPlayer: hapticPlayer,
                     touchParticleSystem: touchParticleSystem,
                     beatsParticleSystem: beatsParticleSystem)
                .background(Color.backgroundColor)
                .onAppear { assignDelegates() }
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            switch newScenePhase {
            case .active:
                hapticPlayer.restart()
            case .background:
                hapticPlayer.stop()
            case .inactive:
                hapticPlayer.stop()
            @unknown default:
                hapticPlayer.stop()
            }
        }
    }
    
    private func assignDelegates() {
        beatsParticleSystem.metronomeDelegate = metronome
    }
}
