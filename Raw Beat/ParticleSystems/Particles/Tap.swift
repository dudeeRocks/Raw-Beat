// Abstract: used for keeping track of user taps for tempo setup.

import SwiftUI

struct Tap: Particle {
    
    // MARK: Particle Required Properties
    
    let creationTime: Double
    var id: String { "Tap-\(creationTime)" }
    
    var didFinishAnimation: Bool = false
    
    var scale: Double = 0.0
    var opacity: Double = 0.0
    
    // MARK: Tap Properties
    
    let location: CGPoint
    
    private let scaleMin: Double = 0.0
    private let scaleMax: Double = 3.0
    
    private let opacityMin: Double = 0.0
    private let opacityMax: Double = 1.0
    
    private let lifetime: Double = 0.5

    // MARK: Particle Required Methods
    
    mutating func update(at currentTime: Double) {
        if didFinishAnimation { return }
        
        let timeSinceCreation: Double = currentTime - creationTime
        let normilizedTime: Double = timeSinceCreation / lifetime
        
        scale = cubicAnimation(time: normilizedTime, p0: scaleMin, p1: scaleMax / 2, p2: scaleMax, p3: scaleMax / 4)
        opacity = cubicAnimation(time: normilizedTime, p0: opacityMin, p1: opacityMax, p2: opacityMax / 2, p3: opacityMin)
        
        if currentTime > creationTime + lifetime { didFinishAnimation = true }
    }
}
