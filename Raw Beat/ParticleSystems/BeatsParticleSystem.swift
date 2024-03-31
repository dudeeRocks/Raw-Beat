// Abstract: model for generating Beat objects for BeatsVisualizer.

import SwiftUI

class BeatsParticleSystem: ObservableObject {
    
    // MARK: Properties
    
    var metronomeDelegate: MetronomeDelegate!
    
    var beats: [Beat] = [] {
        didSet {
            
        }
    }
    
    var lastUpdate: Double = 0.0
    
    private var isPlaying: Bool {
        return metronomeDelegate.isPlaying
    }
    
    private var interval: Double {
        return metronomeDelegate.intervalInSeconds
    }
    
    private var lastBeatTime: Double {
        return metronomeDelegate.lastBeatTime
    }
    
    // MARK: - Methods
    
    func update(at currentTime: Double) {
        if isPlaying {
            beats.removeAll { $0.didFinishAnimation }
            
            if lastUpdate != lastBeatTime {
                createNewBeat(creationTime: CACurrentMediaTime())
                lastUpdate = lastBeatTime
            }
            
            for index in beats.indices {
                beats[index].update(at: currentTime)
            }
        } else {
            if !beats.isEmpty {
                beats = []
                lastUpdate = 0.0
            }
        }
    }
    
    func createNewBeat(creationTime: Double) {
        let isUp: Bool = metronomeDelegate.nextBeat == 1 ? true : false
        let newBeat = Beat(creationTime: creationTime, isUpBeat: isUp)
        beats.append(newBeat)
    }
}
