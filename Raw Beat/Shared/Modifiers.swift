// Abstract: collection of ViewModifiers representing app's style guide.

import SwiftUI

struct Modifiers {
    
    struct TempoText: ViewModifier {
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        
        private var size: Double {
            horizontalSizeClass == .compact ? 150.0 : 250.0
        }
        
        func body(content: Content) -> some View {
            content
                .font(.system(size: size, weight: .black, design: .default))
                .kerning(-5.0)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
    }
    
    struct SymbolStyle: ViewModifier {
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        
        var buttonSize: ButtonSize
        
        private var symbolSize: CGFloat {
            switch buttonSize {
            case .large:
                return horizontalSizeClass == .compact ? buttonSize.symbolSize : buttonSize.symbolSize * 1.2
            default:
                return horizontalSizeClass == .compact ? buttonSize.symbolSize * 0.85 : buttonSize.symbolSize * 1.2
            }
        }
        
        func body(content: Content) -> some View {
            content
                .font(.system(size: symbolSize))
                .bold()
        }
    }
    
    struct MenuTransition: ViewModifier {
        
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        private var offset: CGSize {
            if horizontalSizeClass == .compact {
                return properties.offset
            } else {
                let width: CGFloat = properties.offset.width * 1.5
                let height: CGFloat = properties.offset.height * 1.5
                return CGSize(width: width, height: height)
            }
        }
        
        var state: Bool
        
        var properties: AnimationProperties
        
        func body(content: Content) -> some View {
            content
                .opacity(state ? 1.0 : 0.0)
                .scaleEffect(state ? 1.0 : 0.0001)
                .offset(state ? offset : .zero)
                .animation(.easeIn(duration: 0.3).delay(properties.delay), value: state)
        }
        
        init(for properties: AnimationProperties, state: Bool) {
            self.state = state
            self.properties = properties
        }
    }
    
    struct PositionGetter: ViewModifier {
        let element: AnimationElement
        @Binding var sharedData: SharedData
        
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        
        private var geometryProxy: GeometryProxy {
            return sharedData.mainGeometryProxy
        }
        
        func body(content: Content) -> some View {
            content
                .anchorPreference(key: ViewBounds.self, value: .bounds) { anchor in
                    [element : geometryProxy[anchor]]
                }
                .onPreferenceChange(ViewBounds.self) { value in
                    guard let rect = value[element] else {
                        Log.sharedInstance.log(message: "Couldn't find CGRect for \(element)")
                        return
                    }
                    sharedData.prepareAnimationProperties(for: element, inRect: rect, deviceSize: horizontalSizeClass)
                }
        }
        
        struct ViewBounds: PreferenceKey {
            
            static var defaultValue: [AnimationElement : CGRect] = [:]
            static func reduce(value: inout [AnimationElement: CGRect], nextValue: () -> [AnimationElement: CGRect]) {
                value.merge(nextValue()) { _, new in new }
            }
        }
    }
}

extension View {
    func getPosition(for element: AnimationElement, sharedData: Binding<SharedData>) -> some View {
        modifier(Modifiers.PositionGetter(element: element, sharedData: sharedData))
    }
}
