// abstract: particle for long press effect.

import SwiftUI

struct Pulse: Particle {
    
    // MARK: Particle Required Properties
    
    let creationTime: Double
    var id: String { "Pulse-\(creationTime)" }
    
    var didFinishAnimation: Bool = false
    
    var scale: Double = 0.0
    var opacity: Double = 0.0
    
    // MARK: Pulse Properties
    var location: CGPoint
    
    private let scaleMin: Double = 0.0
    private let scaleMax: Double = 2.0
    
    private let opacityMin: Double = 0.0
    private let opacityMax: Double = 1.0
    
    private let lifetime: Double = 1.0
    
    // MARK: Particle Required Methods
    
    mutating func update(at currentTime: Double) {
        if didFinishAnimation { return }
        
        let timeSinceCreation: Double = currentTime - creationTime
        let normilizedTime: Double = timeSinceCreation / lifetime
        
        scale = quadraticAnimation(time: normilizedTime, from: scaleMin, to: scaleMax)
        opacity = cubicAnimation(time: normilizedTime, p0: opacityMin, p1: opacityMax, p2: opacityMin, p3: opacityMin)
        
        if currentTime > creationTime + lifetime { didFinishAnimation = true }
    }
}
