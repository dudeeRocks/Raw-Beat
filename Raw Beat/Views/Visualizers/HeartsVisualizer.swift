//
//  HeartsVisualizer.swift
//  Raw Beat
//
//  Created by David Katsman on 24/07/2024.
//

import SwiftUI

struct HeartsVisualizer: View {
    @StateObject var model = HeartsParticleSystem()
        
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { canvas, size in

                let time = timeline.date.timeIntervalSinceReferenceDate
                model.update(at: time, size: size)
                
                for heart in model.hearts {
                    canvas.drawLayer { copy in
                        let heartSymbol: Image = Image(systemName: "heart.fill")
                        var image = copy.resolve(heartSymbol)
                        image.shading = .color(.accentColor)
                        let side: CGFloat = (min(size.width, size.height) * 0.1) * heart.scale
                        let rectSize = CGSize(width: side, height: side)
                        let rect = CGRect(origin: heart.location, size: rectSize)
                        copy.opacity = heart.opacity
                        copy.blendMode = .lighten
                        copy.draw(image, in: rect)
                    }
                }
            }
        }
    }
}

#Preview {
    HeartsVisualizer()
}
