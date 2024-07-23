// Abstract: Object representing possible In-App Purchases.

import SwiftUI

enum Tip: String {
    case water, coffee, beer
    
    var emoji: String {
        switch self {
        case .water:
            return "🚰"
        case .coffee:
            return "☕️"
        case .beer:
            return "🍺"
        }
    }
    
    var thankYouNoteContent: (title: LocalizedStringKey, description: LocalizedStringKey) {
        switch self {
        case .water:
            return ("You're a lifesaver!",
                    "Thanks for the hydration boost! My code is flowing smoother already.")
        case .coffee:
            return ("Caffeine Buddy!",
                    "You're the best! This coffee is just what I needed to keep coding through the night.")
        case .beer:
            return ("Cheers to you!",
                    "Thank you so much! This pint is the perfect fuel for my coding adventures.")
        }
    }
}
