// Abstract: Partcile system that animates hearts on the Thank you note

import SwiftUI

class HeartsParticleSystem: ObservableObject {
    
    // MARK: Properties
    
    var hearts: [Heart] = []
    
    private var lastUpdate: Double = 0.0
    
    // MARK: - Methods
    
    func update(at currentTime: Double, size: CGSize) {
        if lastUpdate <= 0.0 {
            lastUpdate = currentTime
            for _ in 0...30 {
                hearts.append(Heart(creationTime: currentTime, canvasSize: size))
            }
        }
        
        let delta: Double = currentTime - lastUpdate
        
        if delta > 1.0 / 30 {
            hearts.append(Heart(creationTime: currentTime, canvasSize: size))
            lastUpdate = currentTime
        }
        
        hearts.removeAll { $0.didFinishAnimation }
        
        for index in hearts.indices {
            hearts[index].update(at: currentTime)
        }
    }
}
