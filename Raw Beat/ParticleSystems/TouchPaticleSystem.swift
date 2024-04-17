// Abstract: model for generating objects on user touches for TouchVisualizer.

import SwiftUI

class TouchPaticleSystem: ObservableObject {
    
    // MARK: Properties
    
    var taps: [Tap] = []
    var pulses: [Pulse] = []
    
    private var tapIntervals: [Double] = []
    private var lastTapTime: Double = 0.0
    
    // MARK: - Methods
    
    func update(at currentTime: Double) {
        
        taps.removeAll { $0.didFinishAnimation }
        pulses.removeAll { $0.didFinishAnimation }
        
        for index in taps.indices {
            taps[index].update(at: currentTime)
        }
        
        for index in pulses.indices {
            pulses[index].update(at: currentTime)
        }
    }
    
    func handle(tap: Tap, do action: (Int?) -> Void) {
        taps.append(tap)
        
        let tapTime: Double = tap.creationTime
        
        let extraMargin: Double = 0.1
        let maxInterval: Double = (60.0 / Double(Metronome.minTempo)) + extraMargin
        
        let intervalBetweenTaps: Double = tapTime - lastTapTime
        lastTapTime = tapTime
        
        if intervalBetweenTaps > maxInterval {
            tapIntervals.removeAll()
        } else {
            switch tapIntervals.count {
            case 0:
                let interpolatedInterval: Double = intervalBetweenTaps
                tapIntervals.append(contentsOf: [interpolatedInterval, intervalBetweenTaps])
                action(nil)
            case 6:
                tapIntervals.append(intervalBetweenTaps)
                action(calculateTempo())
                tapIntervals.removeFirst(2)
            default:
                tapIntervals.append(intervalBetweenTaps)
                action(calculateTempo())
                tapIntervals.removeFirst()
            }
        }
    }
    
    func createPulse(time: Double, location: CGPoint) {
        pulses.append(Pulse(creationTime: time, location: location))
    }
    
    private func calculateTempo() -> Int {
        var averageInterval: Double = 0.0
        var sum: TimeInterval = 0.0
        for interval in tapIntervals {
            sum += interval
        }
        averageInterval = sum / Double(tapIntervals.count)
        
        return Int(60.0 / averageInterval)
    }
}
