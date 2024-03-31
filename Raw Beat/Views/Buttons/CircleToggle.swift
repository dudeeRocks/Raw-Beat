// Abstract: simple custom toggle

import SwiftUI

struct CircleToggle<Label: View>: View {
    
    @Binding var isOn: Bool
    let isOutlined: Bool
    @ViewBuilder let label: () -> Label
    
    var body: some View {
        Toggle(isOn: $isOn) {
            SymbolContainer(frame: 24.0) {
                label()
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .toggleStyle(CircleToggleStyle(isOutlined: isOutlined))
    }
}
