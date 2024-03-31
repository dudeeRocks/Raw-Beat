// Abstract: Common styled button.

import SwiftUI

struct CircleButton<Label: View>: View {
    
    // MARK: Properties
    
    var isOutlined: Bool = false
    let action: () -> Void
    @ViewBuilder var label: () -> Label
    
    // MARK: - Body
    
    var body: some View {
        Button {
            action()
        } label: {
            SymbolContainer(frame: 24.0) {
                label()
            }
        }
        .buttonStyle(CircleButtonStyle(isOutlined: isOutlined))
    }
}
