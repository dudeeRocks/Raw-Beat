// Abstract: Base view for the buttons and toggles.

import SwiftUI

struct ButtonBackground<S: Shape>: View {
    
    var isPressed: Bool
    let isOutlined: Bool
    let shape: S
    
    private var lightColor: Color {
        return Color.gradientStartColor
    }
    
    private var shadowColor: Color {
        return Color.gradientEndColor
    }
    
    private var strokeColor: Color {
        return Color.gradientStartColor.opacity(0.5)
   }
    
    var body: some View {
        ZStack {
            if isOutlined {
                shape
                    .fill(Color.clear)
                    .overlay(shape.stroke(Color.primaryColor, lineWidth: 2.0))
                shape
                    .fill(Color.primaryColor)
                    .scaleEffect(isPressed ? 0.85 : 0.001)
                    .animation(.easeIn(duration: 0.25).delay(0.05), value: isPressed)
            } else {
                if isPressed {
                    shape
                        .fill(Color.buttonFill)
                        .overlay(shape.stroke(strokeColor.blendMode(.screen), lineWidth: 4))
                        .shadow(color: shadowColor, radius: 10, x: -10.0, y: -10.0)
                        .shadow(color: lightColor, radius: 10, x: 5.0, y: 5.0)
                } else {
                    shape
                        .fill(Color.buttonFill)
                        .overlay(shape.stroke(strokeColor.blendMode(.screen), lineWidth: 4))
                        .shadow(color: shadowColor, radius: 10, x: 10.0, y: 10.0)
                        .shadow(color: lightColor, radius: 10, x: -5.0, y: -5.0)
                }
                shape
                    .fill(Color.accentColor.shadow(.inner(color: .black.opacity(0.5), radius: 4, x: 2, y: 2)))
                    .scaleEffect(isPressed ? 1.0 : 0.001)
                    .opacity(isPressed ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.15), value: isPressed)
            }
        }
    }
}
