// Absract: representation of possible Time Signatures.

import Foundation

enum TimeSignature: CaseIterable, Identifiable, AnimatableSelection {
    case threeFourth
    case fourFourth
    case sixEighths
    
    var id: Self { self }
    
    var symbol: String {
        switch self {
        case .threeFourth:
            return "timeSignature.three.fourth"
        case .fourFourth:
            return "timeSignature.four.fourth"
        case .sixEighths:
            return "timeSignature.six.eighth"
        }
    }
    
    var animationProperties: AnimationProperties {
        switch self {
        case .threeFourth:
            return .timeThreeFourth
        case .fourFourth:
            return .timeFourFourth
        case .sixEighths:
            return .timeSixEighths
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .threeFourth:
            return String(localized: "Three fourth", comment: "Accessibility label for time signature.")
        case .fourFourth:
            return String(localized: "Four fourth", comment: "Accessibility label for time signature.")
        case .sixEighths:
            return String(localized: "Six eighth", comment: "Accessibility label for time signature.")
        }
    }
}
