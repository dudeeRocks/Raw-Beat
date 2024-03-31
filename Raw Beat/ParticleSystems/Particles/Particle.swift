// Abstract: simple protocol for animated particles.

import SwiftUI

protocol Particle {
    
    // MARK: Particle Required Properties
    
    var creationTime: Double { get }
    var id: String { get }
    
    var didFinishAnimation: Bool { get set }
    
    var scale: Double { get }
    var opacity: Double { get }
    
    // MARK: Particle Required Methods
    
    mutating func update(at currentTime: Double)
}
