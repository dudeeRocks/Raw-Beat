// Abstract: Container for symbols in buttons to keep the buttons from changing their size due to symbol change.

import SwiftUI

struct SymbolContainer<Label: View>: View {
    
    var frame: CGFloat
    var label: () -> Label
    
    var body: some View {
        ZStack {
            label()
        }
        .frame(width: frame, height: frame, alignment: .center)
    }
}
