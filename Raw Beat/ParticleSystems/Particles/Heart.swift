// Abstract: particle for thank you note

import SwiftUI

struct Heart: Particle {
    
    let creationTime: Double
    let canvasSize: CGSize
    
    let id: String = UUID().uuidString
    
    var didFinishAnimation: Bool = false
    private(set) var scale: Double = 0.0
    private(set) var opacity: Double = 0.0
    private(set) var location: CGPoint = .zero
    
    private var endLocation: CGPoint = .zero
        private var centerPoint: CGPoint {
            CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        }
    
    private let lifetime: Double
    
    // MARK: Initializers
        
    init(creationTime: Double, canvasSize: CGSize) {
        self.creationTime = creationTime
        self.canvasSize = canvasSize
        self.lifetime = .random(in: 1.5 ..< 3.0)
        self.endLocation = randomPoint()
    }
    
    // MARK: Particle Required Methods
    
    mutating func update(at currentTime: Double) {
        if didFinishAnimation { return }

        let timeSinceCreation: Double = currentTime - creationTime
        let normalizedTime: Double = timeSinceCreation / lifetime

        scale = quadraticAnimation(time: normalizedTime, from: 0.0, to: 1.0)
        opacity = quadraticAnimation(time: normalizedTime, from: 1.0, to: 0.0)
        location.x = quadraticAnimation(time: normalizedTime, from: centerPoint.x, to: endLocation.x)
        location.y = quadraticAnimation(time: normalizedTime, from: centerPoint.y, to: endLocation.y)

        if currentTime > creationTime + lifetime { didFinishAnimation = true }
    }
    
    // MARK: Heart particle methods
    
    private func randomPoint() -> CGPoint {
       let radius: CGFloat = (min(canvasSize.width, canvasSize.height) / 2)
       let angle: CGFloat = .random(in: -.pi ..< .pi)
       let distance: CGFloat = .random(in: radius*0.1..<radius)
       let offsetX: CGFloat = distance * cos(angle)
       let offsetY: CGFloat = distance * sin(angle)
       let randomPoint: CGPoint = CGPoint(x: centerPoint.x + offsetX, y: centerPoint.y + offsetY)
       let clampedX: CGFloat = min(max(0, randomPoint.x), canvasSize.width)
       let clampedY: CGFloat = min(max(0, randomPoint.y), canvasSize.height)
       let clampedPoint =  CGPoint(x: clampedX, y: clampedY)
       
       return clampedPoint
   }
}
