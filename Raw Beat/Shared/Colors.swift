// Abstract: colors for the app.

import SwiftUI

extension Color {
    static let accentColor: Color = Color("AccentColor")
    static let primaryColor: Color = Color("PrimaryColor")
    static let backgroundColor: Color = Color("BackgroundColor")
    
    // MARK: Button Colors
    static let buttonFillColor: Color = Color("ButtonFillColor")
    static let label: Color = Color("ButtonLabelColor")
    
    // MARK: Gradient Colors
    static let gradientStartColor: Color = Color("GradientStartColor")
    static let gradientEndColor: Color = Color("GradientEndColor")
}

extension LinearGradient {
    init(colors: Color...) {
        self.init(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
