// Abstract: model of a particle for beats for play animation

import SwiftUI
import os

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
    private let scaleMax: Double = 1.8
    
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
        
        scale = cubicAnimation(time: normalizedTime, p0: scaleMin, p1: scaleMax / 2, p2: scaleMax, p3: scaleMax - scaleMin / 2)
        opacity = quadraticAnimation(time: normalizedTime, from: opacityMax, to: opacityMin)
        
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
