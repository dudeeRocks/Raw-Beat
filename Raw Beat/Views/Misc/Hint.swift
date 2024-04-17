// Abstract: A View that manages display of relevant text hints.

import SwiftUI

struct Hint: View {
    
    @Binding var sharedData: SharedData
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var size: Double {
        horizontalSizeClass == .compact ? 18.0 : 28.0
    }
    
    private var contentWidth: Double {
        horizontalSizeClass == .compact ? 300.0 : 500.0
    }
    
    private var isHintShown: Bool {
        sharedData.hint != .none
    }
    
    var body: some View {
        if sharedData.didMeasureScrollItem {
            if isHintShown {
                VStack(spacing: 16) {
                    Image(systemName: sharedData.hint.symbol)
                        .accessibilityHidden(true)
                        .symbolEffect(.bounce, options: .repeat(2))
                        .font(.system(size: size * 1.5, weight: .medium, design: .default))
                    Text(sharedData.hint.text)
                        .accessibilityIdentifier(ViewIdentifiers.hint.rawValue)
                        .font(.system(size: size, weight: .medium, design: .default))
                }
                .frame(width: contentWidth)
                .multilineTextAlignment(.center)
                .opacity(isHintShown ? 1.0 : 0.0)
                .offset(x: 0, y: -sharedData.getHintOffset())
                .onAppear {
                    switch sharedData.hint {
                    case .none:
                        return
                    case .firstTimeExperience:
                        resetHintAfter(seconds: GlobalProperties.fteDuration)
                    case .volumeOff:
                        resetHintAfter(seconds: 3)
                    default:
                        resetHintAfter(seconds: 2)
                    }
                }
            }
        }
    }
    
    // MARK: Methods
    
    private func resetHintAfter(seconds deadline: TimeInterval) {
        Task(priority: .userInitiated) {
            try await Task.sleep(for: .seconds(deadline))
            withAnimation(Animations.hint) {
                sharedData.setHint(to: .none)
            }
        }
    }
}
