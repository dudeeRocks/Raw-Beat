// Abstract: Container for symbols in buttons to keep the buttons from changing their size due to symbol change.

import SwiftUI

struct SymbolContainer<Label: View>: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var frame: CGFloat
    var label: () -> Label
    
    private var adaptiveSize: CGFloat {
        horizontalSizeClass == .compact ? frame : frame * 2.0
    }
    
    var body: some View {
        ZStack {
            label()
        }
        .frame(width: adaptiveSize, height: adaptiveSize, alignment: .center)
    }
}
