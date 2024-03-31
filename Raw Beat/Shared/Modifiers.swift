// Abstract: collection of ViewModifiers representing app's style guide.

import SwiftUI

struct Modifiers {
    
    struct TempoText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 150, weight: .black, design: .default))
                .kerning(-5.0)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
    }
    
    struct SymbolStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 20))
                .bold()
        }
    }
    
    struct MenuTransition: ViewModifier {
        
        var state: Bool
        
        var properties: AnimationProperties
        
        func body(content: Content) -> some View {
            content
                .opacity(state ? 1.0 : 0.0)
                .scaleEffect(state ? 1.0 : 0.0001)
                .offset(state ? properties.offset : .zero)
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
                        print("Couldn't find CGRect for \(element)")
                        return
                    }
                    sharedData.prepareAnimationProperties(for: element, inRect: rect)
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
