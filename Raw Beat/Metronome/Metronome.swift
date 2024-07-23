// Abstract: This is the metronome logic responsible for playing relevant sounds at the right time in a correct pattern.

import SwiftUI
import AVFoundation

class Metronome: MetronomeDelegate, ObservableObject {
    
    // MARK:  Type Properties
    
    static let maxTempo: Int = 240
    static let minTempo: Int = 40
    
    // MARK: - Published Properties
    
    @Published var tempo: Int = 120 {
        didSet {
            capTempoToMinAndMax()
            setIntervalInSeconds()
        }
    }
    
    @Published var timeSignature: TimeSignature = .fourFourth {
        didSet {
            setBeatsPerMeasure()
        }
    }
    
    @Published var sound: Sound = .tick {
        didSet {
            prepareSoundsToPlay()
        }
    }
   
    // MARK: - MetronomeDelegate Properties

    @Published var isPlaying: Bool = false
    var lastBeatTime: Double = 0.0
    var intervalInSeconds: Double = 0.5
    var beatsPerMeasure: Int = 4
    var nextBeat: Int = 1
    
    // MARK: - AVFoundation Properties
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var playerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    
    private var upBeat: AVAudioFile = AVAudioFile()
    private var downBeat: AVAudioFile = AVAudioFile()
    
    private var nextBeatFramePosition: AVAudioFramePosition = 0
    
    var isVolumeOff: Bool {
        audioSession.outputVolume == 0.0
    }
    
    // MARK: - Methods
    func play() {
        isPlaying = true
        activateAudioSession()
        startEngine()
        scheduleBeat()
    }
    
    func stop() {
        isPlaying = false
        playerNode.stop()
        audioEngine.stop()
        deactivateAudioSession()
    }
    
    func setTempo(to value: Int) throws {
        guard value >= Metronome.minTempo else {
            throw MetronomeError.newTempoLessThanMinTempo
        }
        guard value <= Metronome.maxTempo else {
            throw MetronomeError.newTempoMoreThanMaxTempo
        }
        tempo = value
    }
    
    private func setIntervalInSeconds() {
        intervalInSeconds = 60.0 / Double(tempo)
    }
    
    private func capTempoToMinAndMax() {
        if tempo < Metronome.minTempo {
            self.tempo = Metronome.minTempo
        }
        if tempo > Metronome.maxTempo {
            self.tempo = Metronome.maxTempo
        }
    }
    
    private func setBeatsPerMeasure() {
        switch self.timeSignature {
        case .threeFourth:
            beatsPerMeasure = 3
        case .fourFourth:
            beatsPerMeasure = 4
        case .sixEighths:
            beatsPerMeasure = 6
        }
    }
    
    private func setUpNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleNotiication),
                                       name: AVAudioSession.interruptionNotification,
                                       object: AVAudioSession.sharedInstance())
    }
    
    @objc private func handleNotiication(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            stop()
        case .ended:
            play()
        default:
            return
        }
    }
    
    // MARK: - AVFoundation Methods
    
    private func activateAudioSession() {
        do {
            try audioSession.setActive(true)
        } catch {
            Log.sharedInstance.log(error: "Couldn't set the audio session to active. Error: \(error.localizedDescription)")
        }
    }
    
    private func deactivateAudioSession() {
        do {
            try audioSession.setActive(false)
        } catch {
            Log.sharedInstance.log(error: "Couldn't deactivate the audio session. Error: \(error.localizedDescription)")
        }
    }
    
    private func startEngine() {
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                Log.sharedInstance.log(error: "Couldn't start audio engine. Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleBeat() {
        if isPlaying {
            let file: AVAudioFile = nextBeat == 1 ? upBeat : downBeat
            let sampleRate: Double = file.processingFormat.sampleRate
            let time: AVAudioTime = AVAudioTime(sampleTime: nextBeatFramePosition, atRate: sampleRate)
            let framesPerInterval: AVAudioFramePosition = AVAudioFramePosition(intervalInSeconds * sampleRate)
            
            Task {
                await playerNode.scheduleFile(file, at: time, completionCallbackType: .dataRendered)
                
                updateNextBeat()
                scheduleBeat()
            }
            
            playerNode.play()
            
            lastBeatTime = CACurrentMediaTime()
            nextBeatFramePosition += framesPerInterval
            
        } else {
            lastBeatTime = 0.0
            nextBeat = 1
            nextBeatFramePosition = 0
        }
    }
    
    private func updateNextBeat() {
        if nextBeat >= beatsPerMeasure {
            nextBeat = 1
        } else {
            nextBeat += 1
        }
    }
    
    private func prepareSoundsToPlay() {
        do {
            let url = sound.url
            upBeat = try AVAudioFile(forReading: url.upBeat)
            downBeat = try AVAudioFile(forReading: url.downBeat)
            
        } catch let error {
            Log.sharedInstance.log(error: "Couldn't prepare sounds to play. Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Initializers
    /// Metronome is initialized on app launch inside `MetronomeApp`as a `StateObject` ensuring that `AVAudioSession` configuration happens as early as possible.
    init() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        } catch let error {
            Log.sharedInstance.log(error: "Couldn't set the audio session to playback category. Error: \(error.localizedDescription)")
        }
        self.prepareSoundsToPlay()
        self.setUpNotifications()
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.outputNode, format: upBeat.processingFormat)
    }
}

protocol AnimatableSelection {
    var animationProperties: AnimationProperties { get }
}
