// Abstract: Collection of methods to animate particles.

import Foundation

extension Particle {
    func linearAnimation(time t: Double, from p0: Double, to p1: Double) -> Double {
        return (1.0 - t) * p0 + t * p1
    }
    
    func quadraticAnimation(time t: Double, from p0: Double, to p2: Double) -> Double {
        let p1: Double = (p0 + p2) / 2
        
        return pow((1 - t), 2.0) * p0 + 2 * t * (1 - t) * p1 + pow(t, 2.0) * p2
    }
    
    func cubicAnimation(time t: Double, from p0: Double, to p3: Double) -> Double {
        let p1: Double = p3 > p0 ? p3 / 2 : p0 / 2
        let p2: Double = p3 > p0 ? p3 : p0
        
        return pow((1 - t), 3.0) * p0 + 3 * t * pow((1 - t), 2.0) * p1 + 3 * pow(t, 2.0) * (1 - t) * p2 + pow(t, 2.0) * p3
    }
    
    func cubicAnimation(time t: Double, p0: Double, p1: Double, p2: Double, p3: Double) -> Double {
        return pow((1 - t), 3.0) * p0 + 3 * t * pow((1 - t), 2.0) * p1 + 3 * pow(t, 2.0) * (1 - t) * p2 + pow(t, 2.0) * p3
    }
    
    func angularAnimation(currentTime: Double, duration: Double, amplitude: Double, isAccelerating: Bool = true) -> Double {
        let angularVelocity: Double = (2 * Double.pi) / duration
        
        if isAccelerating {
            return amplitude * cos(angularVelocity * currentTime)
        } else {
            return amplitude * sin(angularVelocity * currentTime)
        }
    }
}
