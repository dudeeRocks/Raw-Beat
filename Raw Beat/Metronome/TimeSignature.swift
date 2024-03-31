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
            return "Three fourth"
        case .fourFourth:
            return "Four fourth"
        case .sixEighths:
            return "Six eighth"
        }
    }
}
