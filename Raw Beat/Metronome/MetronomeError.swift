// Abstract: Metronome errors.

import Foundation

enum MetronomeError: Error {
    case newTempoMoreThanMaxTempo
    case newTempoLessThanMinTempo
    
    var description: String {
        switch self {
        case .newTempoLessThanMinTempo:
            return "Minimum tempo is \(Metronome.minTempo) BPM."
        case .newTempoMoreThanMaxTempo:
            return "Maximum tempo is \(Metronome.maxTempo) BPM."
        }
    }
}
