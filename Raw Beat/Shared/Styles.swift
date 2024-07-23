// Abstract: Collection of button styles.

import SwiftUI

struct CustomButton<S: Shape>: ButtonStyle {
    
    let isOutlined: Bool
    var size: ButtonSize = .medium
    var shape: S
    
    func makeBody(configuration: Configuration) -> some View {
        var labelColor: Color {
            if isOutlined {
                configuration.isPressed ? Color.label : Color.primaryColor
            } else {
                Color.label
            }
        }
        
        return configuration.label
            .modifier(Modifiers.SymbolStyle(buttonSize: size))
            .foregroundStyle(labelColor)
            .padding(.all, size.padding)
            .clipShape(shape)
            .background {
                ButtonBackground(isPressed: configuration.isPressed, isOutlined: isOutlined, shape: shape)
            }
    }
}

struct CircleButtonStyleForToggle: ButtonStyle {
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    
    var isPressed: Bool
    let isOutlined: Bool
    var size: ButtonSize = .medium
    
    private var labelStyle: Color {
        if isOutlined {
            if colorScheme == .dark {
                return isPressed ? Color.buttonFill : Color.label
            } else {
                return isPressed ? Color.label : Color.buttonFill
            }
        } else {
            return Color.label
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(Modifiers.SymbolStyle(buttonSize: size))
            .foregroundStyle(labelStyle)
            .padding(.all, size.padding)
            .clipShape(Circle())
            .background {
                ButtonBackground(isPressed: isPressed || configuration.isPressed, isOutlined: isOutlined, shape: Circle())
            }
    }
}

struct CircleToggleStyle: ToggleStyle {
    
    let isOutlined: Bool
    var size: ButtonSize = .medium
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
                .modifier(Modifiers.SymbolStyle(buttonSize: size))
        }
        .buttonStyle(CircleButtonStyleForToggle(isPressed: configuration.isOn, isOutlined: isOutlined, size: size))
    }
}

enum ButtonSize {
    case small, medium, large
    
    var padding: CGFloat {
        switch self {
        case .small:
            return 12
        case .medium:
            return 22
        case .large:
            return 36
        }
    }
    
    var symbolSize: CGFloat {
        switch self {
        case .small:
            return 16
        case .medium:
            return 24
        case .large:
            return 36
        }
    }
}
