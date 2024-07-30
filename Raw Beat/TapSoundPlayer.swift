// Abstract: Object for playing sounds on tap.

import AVFoundation

class TapSoundPlayer {
    
    private let player: AVAudioPlayer?
    
    init() {
        guard let sound = Bundle.main.url(forResource: "tapSound", withExtension: "aif") else {
            Log.sharedInstance.log(message: "Couldn't locate tap sound file.")
            player = nil
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: sound)
        } catch {
            Log.sharedInstance.log(error: error.localizedDescription)
            player = nil
        }
    }
    
    func play() {
        player?.play()
    }
}
