// Absract: representation of possible sounds.

import Foundation

enum Sound: CaseIterable, Identifiable, AnimatableSelection {
    case tick
    case hihat
    case kick
    
    var id: Self { self }
    
    var symbol: String {
        switch self {
        case .tick:
            return "sound.woodblock"
        case .hihat:
            return "sound.hihat"
        case .kick:
            return "sound.fx"
        }
    }
    
    var url: (upBeat: URL, downBeat: URL) {
        var fileName: String {
            switch self {
            case .tick:
                return "tick"
            case .hihat:
                return "hihat"
            case .kick:
                return "kick"
            }
        }
        guard let upBeatURL = Bundle.main.url(forResource: fileName + "Up", withExtension: "aif") else { fatalError("Can't get the file for strong beat.") }
        guard let downBeatURL = Bundle.main.url(forResource: fileName + "Down", withExtension: "aif") else { fatalError("Can't get the file for weak beat.") }
        
        return (upBeatURL, downBeatURL)
    }
    
    var animationProperties: AnimationProperties {
        switch self {
        case .tick:
            return .soundTick
        case .hihat:
            return .soundHihat
        case .kick:
            return .soundKick
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .tick:
            return String(localized: "Woodblock", comment: "Accessibility label for sound.")
        case .hihat:
            return String(localized: "Hi Hat", comment: "Accessibility label for sound.")
        case .kick:
            return String(localized: "Sound effect", comment: "Accessibility label for sound.")
        }
    }
}
