// Abstract: model of a particle for beats for play animation

import SwiftUI

struct Beat: Particle {
    
    // MARK: Particle Properties
    
    var creationTime: Double
    var id: String { "Beat-\(creationTime)" }
    
    var didFinishAnimation: Bool = false
    
    var scale: Double = 0.0
    var opacity: Double = 0.0
    
    // MARK: Beat Properties
    
    var isUpBeat: Bool
    
    private let scaleMin: Double = 1.0
    private let scaleMax: Double = 2.0
    
    private let opacityMin: Double = 0.0
    private let opacityMax: Double = 1.0
    
    private let lifetime: Double = 1.0
    
    // MARK: Initialization
    
    init(creationTime: Double, isUpBeat: Bool) {
        self.creationTime = creationTime
        self.isUpBeat = isUpBeat
    }
    // MARK: Methods
    
    mutating func update(at currentTime: Double) {
        
        if didFinishAnimation { return }
        
        let timeSinceCreation: Double = currentTime - creationTime
        let normalizedTime: Double = timeSinceCreation / lifetime
        
        scale = quadraticAnimation(time: normalizedTime, from: scaleMin, to: scaleMax)
        opacity = cubicAnimation(time: normalizedTime, p0: opacityMin, p1: opacityMax, p2: opacityMin, p3: opacityMin)
        
        if currentTime >= creationTime + lifetime {
            didFinishAnimation = true
        }
    }
}

extension Beat: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(creationTime)
        hasher.combine(didFinishAnimation)
    }
}

extension Beat: Equatable {
    static func == (lhs: Beat, rhs: Beat) -> Bool {
        lhs.creationTime == rhs.creationTime
    }
}
