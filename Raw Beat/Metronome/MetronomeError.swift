// Abstract: Metronome errors.

import Foundation

enum MetronomeError: Error {
    case newTempoMoreThanMaxTempo
    case newTempoLessThanMinTempo
    
    var description: String {
        switch self {
        case .newTempoLessThanMinTempo:
            return String(localized: "Minimum tempo is \(Metronome.minTempo) BPM.", comment: "Invalid input error.")
        case .newTempoMoreThanMaxTempo:
            return String(localized: "Maximum tempo is \(Metronome.maxTempo) BPM.", comment: "Invalid input error.")
        }
    }
}
