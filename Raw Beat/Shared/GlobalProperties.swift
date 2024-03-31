// Abstract: Properties shared among many parts of the app.

import SwiftUI

struct GlobalProperties {
    static let longPressDuration: CGFloat = 0.3
    
    struct Scroll {
        static let visibleScrollItems: Int = 20
        static let timeToHide: Double = 1.5
        static let timeToSubmit: Double = 0.5
    }
}
