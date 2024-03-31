// Abstract: Delegate for communication between Metronome and other models.

import Foundation

protocol MetronomeDelegate: AnyObject {
    var isPlaying: Bool { get set }
    var lastBeatTime: Double { get set }
    var intervalInSeconds: Double { get set }
    var beatsPerMeasure: Int { get set }
    var nextBeat: Int { get set }
}
