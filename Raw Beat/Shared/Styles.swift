// Abstract: Collection of button styles.

import SwiftUI

struct CircleButtonStyle: ButtonStyle {
    
    let isOutlined: Bool
    var size: ButtonSize = .medium
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(Modifiers.SymbolStyle())
            .foregroundStyle(Color.label)
            .padding(.all, size.padding)
            .clipShape(Circle())
            .background {
                ButtonBackground(isPressed: configuration.isPressed, isOutlined: isOutlined, shape: Circle())
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
            .modifier(Modifiers.SymbolStyle())
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
                .modifier(Modifiers.SymbolStyle())
        }
        .buttonStyle(CircleButtonStyleForToggle(isPressed: configuration.isOn, isOutlined: isOutlined, size: size))
    }
}

enum ButtonSize {
    case small, medium, large
    
    var padding: CGFloat {
        switch self {
        case .small:
            return 16
        case .medium:
            return 22
        case .large:
            return 36
        }
    }
}
