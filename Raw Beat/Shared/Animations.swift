// Abstract: an easy way to keep track of animations and timing them together.

import SwiftUI

struct Animations {
    static let buttonBar: Animation = .easeOut(duration: DurationPreset.mid.value)
    
    static let buttonPress: Animation = .easeIn(duration: DurationPreset.min.value)
    
    static let buttonRelease: Animation = .easeOut(duration: DurationPreset.min.value).delay(DurationPreset.min.value)
    
    static let fieldShake: Animation = .spring(response: 0.1, dampingFraction: 0.1)
    
    static let hint: Animation = .easeOut(duration: DurationPreset.mid.value)
    
    static let errorMessage: Animation = .easeOut(duration: DurationPreset.mid.value)
    
    static let menuOpen: Animation = .easeOut(duration: DurationPreset.mid.value).delay(DurationPreset.min.value)
    
    static let menuClose: Animation = .easeOut(duration: DurationPreset.mid.value).delay(DurationPreset.min.value)
    
    static let tempoField: Animation = .easeIn(duration: DurationPreset.min.value).delay(DurationPreset.max.value)
    
    static let toggle: Animation = .easeInOut(duration: DurationPreset.mid.value)
    
    static let scroll: Animation = .easeIn(duration: DurationPreset.min.value)
    
    static let startGame: Animation = .easeIn(duration: DurationPreset.mid.value)
    
    enum DurationPreset {
        case min, mid, max
        
        var value: Double {
            switch self {
            case .min:
                return 0.15
            case .mid:
                return 0.30
            case .max:
                return 0.50
            }
        }
    }
}

enum AnimationElement {
    case playButton
    case tempoText
    case soundPicker
    case timePicker
}

enum AnimationProperties {
    case playButton
    case tempoText
    case soundKick
    case soundTick
    case soundHihat
    case timeThreeFourth
    case timeFourFourth
    case timeSixEighths
    
    var offset: CGSize {
        switch self {
        case .soundTick:
            return CGSize(width: 0, height: -100)
        case .soundHihat:
            return CGSize(width: 100, height: -100)
        case .soundKick:
            return CGSize(width: 100, height: 0)
        case .timeThreeFourth:
            return CGSize(width: 0, height: -100)
        case .timeFourFourth:
            return CGSize(width: -100, height: -100)
        case .timeSixEighths:
            return CGSize(width: -100, height: 0)
        default:
            return .zero
        }
    }
    
    var delay: Double {
        switch self {
        case .soundKick, .timeSixEighths:
            return 0.2
        case .soundHihat, .timeFourFourth:
            return 0.1
        default:
            return 0.0
        }
    }
}
