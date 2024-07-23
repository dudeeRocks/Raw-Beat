// Abstract: View that appears at the top of main UI.

import SwiftUI

struct Header: View {
    
    @StateObject private var store = Store()
    
    @State private var isSheetPresented: Bool = false
    @State private var sheetHeight: CGFloat = .zero
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var padding: EdgeInsets {
        let top: CGFloat = 20.0, sides = 32.0, bottom = 0.0
        let factor: CGFloat = horizontalSizeClass == .compact ? 1.0 : 2.0
        return EdgeInsets(top: top * factor,
                          leading: sides * factor,
                          bottom: bottom * factor,
                          trailing: sides * factor)
    }
    
    var body: some View {
        HStack {
            Spacer()
            CircleButton(size: .small) {
                isSheetPresented = true
            } label: {
                Image(systemName: "info")
            }
            .sheet(isPresented: $isSheetPresented) {
                InfoView()
                    .environmentObject(store)
                    .overlay {
                        GeometryReader { geometry in
                            Color.clear.preference(key: InfoViewHeight.self, value: geometry.size.height)
                        }
                    }
                    .onPreferenceChange(InfoViewHeight.self, perform: { value in
                        sheetHeight = value
                    })
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24.0)
                    .presentationBackground {
                        LinearGradient(colors: .gradientStartColor, .gradientEndColor)
                            .opacity(0.3)
                            .background(.ultraThinMaterial)
                    }
            }
        }
        .padding(padding)
    }
}

struct InfoViewHeight: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    Header()
}
