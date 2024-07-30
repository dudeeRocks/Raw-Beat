// Abstract: Common styled button.

import SwiftUI

struct CircleButton<Label: View>: View {
    
    // MARK: Properties
    
    var isOutlined: Bool = false
    var size: ButtonSize = .medium
    let action: () -> Void
    @ViewBuilder var label: () -> Label
    
    // MARK: - Body
    
    var body: some View {
        Button {
            action()
        } label: {
            SymbolContainer(frame: size.symbolSize) {
                label()
            }
        }
        .buttonStyle(CustomButton(isOutlined: isOutlined, size: size, shape: Circle()))
    }
}
