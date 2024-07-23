// Abstract: Model to manage haptic feedback.

import UIKit
import CoreHaptics

class HapticsPlayer: ObservableObject {
    
    // MARK: - UIFeedbackGenerator
    
    var defaultFeedbackGenerator: UINotificationFeedbackGenerator? = nil
    
    // MARK: - CoreHaptics Properties
    
    private var supportsHaptic: Bool = false
    private var hapticEngine: CHHapticEngine!
    
    // MARK: Patterns
    private var longPressUpdatingPattern: CHHapticPattern!
    private var longPressEndedPattern: CHHapticPattern!
    private var scrollPattern: CHHapticPattern!
    
    // MARK: Players
    private var longPressUpdatingPlayer: CHHapticPatternPlayer!
    private var longPressEndedPlayer: CHHapticPatternPlayer!
    private var scrollPlayer: CHHapticPatternPlayer!
    
    // MARK: - Initializers
    
    init() {
        createAndPrepareFeedbackGenerator()
        
        checkHapticsCapability()
        
        if supportsHaptic {
            createAndStartHapticEngine()
            createPatterns()
            createPlayers()
        }
    }
    
    // MARK: - UIFeedbackGenerator Methods
    
    private func createAndPrepareFeedbackGenerator() {
        defaultFeedbackGenerator = UINotificationFeedbackGenerator()
        defaultFeedbackGenerator?.prepare()
    }
    
    // MARK: - CoreHaptics Methods
    
    private func checkHapticsCapability() {
        let hapticsCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptic = hapticsCapability.supportsHaptics
    }
    
    private func createAndStartHapticEngine() {
        if !supportsHaptic { return }
        
        do {
            hapticEngine = try CHHapticEngine()
        } catch {
            Log.sharedInstance.log(error: "Couldn't create hapticEngine. Error: \(error.localizedDescription)")
        }
        
        hapticEngine.stoppedHandler = { reason in
            Log.sharedInstance.log(message: "Stop Handler: The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt: Log.sharedInstance.log(message: "Audio session interrupt")
            case .applicationSuspended: Log.sharedInstance.log(message: "Application suspended")
            case .idleTimeout: Log.sharedInstance.log(message: "Idle timeout")
            case .systemError: Log.sharedInstance.log(error: "System error")
            @unknown default:
                Log.sharedInstance.log(error: "Unknown error")
            }
        }
        
        hapticEngine.resetHandler = {
            Log.sharedInstance.log(message: "Restarting haptics engine.")
            do {
                try self.hapticEngine.start()
                self.createPlayers()
            } catch {
                Log.sharedInstance.log(error: "Failed to restart haptics engine. Error: \(error.localizedDescription)")
            }
        }
        
        do {
            try hapticEngine.start()
        } catch {
            Log.sharedInstance.log(error: "Failed to start the haptic engine. Error: \(error.localizedDescription)")
        }
    }
    
    private func createPatterns() {
        
        createLongPressUpdatingPattern()
        createLongPressEndedPattern()
        createScrollPattern()
        
        func createLongPressUpdatingPattern() {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            
            let controlPoints: [CHHapticParameterCurve.ControlPoint] = [
                .init(relativeTime: 0.0, value: -1.0),
                .init(relativeTime: GlobalProperties.longPressDuration, value: 1.0)
            ]
            
            let intensityCurve = CHHapticParameterCurve(parameterID: .hapticIntensityControl,
                                               controlPoints: controlPoints,
                                               relativeTime: 0)
            
            let sharpnessCurve = CHHapticParameterCurve(parameterID: .hapticSharpnessControl,
                                               controlPoints: controlPoints,
                                               relativeTime: 0)
            
            let event = CHHapticEvent(eventType: .hapticContinuous,
                          parameters: [intensity, sharpness],
                          relativeTime: 0,
                          duration: GlobalProperties.longPressDuration)
            
            do {
                longPressUpdatingPattern = try CHHapticPattern(events: [event],
                                                               parameterCurves: [intensityCurve, sharpnessCurve])
            } catch {
                Log.sharedInstance.log(error: "Failed to create 'longPressUpdatingPattern'. Error: \(error.localizedDescription)")
            }
        }
        
        func createLongPressEndedPattern() {
            let intensityFirstTap = CHHapticEventParameter(parameterID: .hapticIntensity,value: 0.5)
            let intensitySecondTap = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            
            let firstTap = CHHapticEvent(eventType: .hapticTransient,
                                         parameters: [intensityFirstTap, sharpness],
                                         relativeTime: 0.0)
            
            let secondTap = CHHapticEvent(eventType: .hapticTransient,
                                          parameters: [intensitySecondTap, sharpness],
                                          relativeTime: 0.15)
            
            do {
                longPressEndedPattern = try CHHapticPattern(events: [firstTap, secondTap], parameters: [])
            } catch {
                Log.sharedInstance.log(error: "Failed to create 'longPressEndedPattern'. Error: \(error.localizedDescription)")
            }
        }
        
        func createScrollPattern() {
            let intencity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intencity, sharpness], relativeTime: 0.0)
            
            do {
                scrollPattern = try CHHapticPattern(events: [event], parameters: [])
            } catch {
                Log.sharedInstance.log(error: "Failed to create 'scrollPattern'. Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func createPlayers() {
        do {
            longPressUpdatingPlayer = try hapticEngine.makePlayer(with: longPressUpdatingPattern)
        } catch {
            Log.sharedInstance.log(error: "Failed to create 'longPressUpdatingPlayer'. Error: \(error.localizedDescription)")
        }
        
        do {
            longPressEndedPlayer = try hapticEngine.makePlayer(with: longPressEndedPattern)
        } catch {
            Log.sharedInstance.log(error: "Failed to create 'longPressEndedPlayer'. Error: \(error.localizedDescription)")
        }
        
        do {
            scrollPlayer = try hapticEngine.makePlayer(with: scrollPattern)
        } catch {
            Log.sharedInstance.log(error: "Failed to create 'scrollPlayer'. Error \(error.localizedDescription)")
        }
    }
    
    // MARK: - Player Controls
    
    func play(pattern: FeedbackPattern) {
        if !supportsHaptic { return }
        
        switch pattern {
        case .longPressUpdating:
                    do {
                        try longPressUpdatingPlayer.start(atTime: CHHapticTimeImmediate)
                    } catch {
                        Log.sharedInstance.log(error: "Failed to start 'longPressUpdatingPlayer'. Error: \(error.localizedDescription)")

                    }
        case .longPressEnded:
            do {
                try longPressEndedPlayer.start(atTime: CHHapticTimeImmediate)
            } catch {
                Log.sharedInstance.log(error: "Failed to start 'longPressEndedPlayer'. Error: \(error.localizedDescription)")
            }
        case .scroll:
            do {
                try scrollPlayer.start(atTime: CHHapticTimeImmediate)
            } catch {
                Log.sharedInstance.log(error: "Failed to start 'scrollPlayer'. Error: \(error.localizedDescription)")
            }
        }
    }
    
    func stop() {
        if !supportsHaptic { return }
        hapticEngine.stop()
    }
    
    func restart() {
        if !supportsHaptic { return }
        
        do {
            try hapticEngine.start()
        } catch {
            Log.sharedInstance.log(error: "Failed to restart the engine. Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Nested Types
    
    enum FeedbackPattern {
        case longPressUpdating, longPressEnded, scroll
    }
}
