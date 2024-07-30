// Abstract: Object representing possible In-App Purchases.

import SwiftUI

enum Tip: String, CaseIterable, Identifiable {
    case water, coffee, beer
    
    var id: String { UUID().uuidString }
    
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
    
    var thankYouNoteContent: (title: String, description: String) {
        switch self {
        case .water:
            return (String(localized: "You rock!", comment: "Title on thank you note for 'water' tip."),
                    String(localized: "Thank you for the hydration boost!", comment: "Description on thank you note for 'water' tip."))
        case .coffee:
            return (String(localized: "You're amazing!", comment: "Title on thank you note for 'coffee' tip."),
                    String(localized: "Thank you! This coffee keeps me buzzing!", comment: "Description on thank you note for 'coffee' tip."))
        case .beer:
            return (String(localized: "You're awesome!", comment: "Title on thank you note for 'beer' tip."),
                    String(localized: "Thank you for the perfect fuel for my coding.", comment: "Description on thank you note for 'beer' tip."))
        }
    }
}
