// Abstract: Properties shared among many parts of the app.

import SwiftUI

struct GlobalProperties {
    static let longPressDuration: Double = 0.3
    static let fteDuration: Double = 5.0
    
    struct Scroll {
        static let visibleScrollItems: Int = 20
        static let timeToHide: Double = 1.5
        static let timeToSubmit: Double = 0.5
    }
}
