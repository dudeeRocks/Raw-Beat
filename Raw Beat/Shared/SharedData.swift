// Abstract: Data to be shared between Views

import SwiftUI

struct SharedData {
    
    // MARK: - Properties
    
    var overlayState: OverlayState = .none
    var pickerState: PickerState = .none
    var hint: Hint = .none
    var errorMessage: ErrorMessage = .none
    
    var newTempo: Int = 0
    var oldTempo: Int = 0
    
    var isFieldShaking: Bool = false
    var tempoFieldTaps: Int = 0
    var tempoFieldLastTapTime: Double = 0.0
    
    var scrollViewProxy: ScrollViewProxy!
    var scrollItemHeight: CGFloat!
    var didMeasureScrollItem: Bool = false
    var didScrollDisappear: Bool = false
    var isReadyForScrolling: Bool = false
    
    var mainGeometryProxy: GeometryProxy!
    var didSetMainGeometryProxy: Bool = false
    var animationSizes: [AnimationElement: CGFloat] = [:]
    var animationPositions: [AnimationProperties : CGPoint] = [:]
    
    var tempoName: String = ""
    let tempoRanges: [String: Range<Int>] = [
        "Lento"         :   Metronome.minTempo..<50,
        "Largo"         :   50..<60,
        "Larghetto"     :   60..<66,
        "Adagio"        :   66..<76,
        "Andante"       :   76..<108,
        "Moderato"      :   108..<121,
        "Allegretto"    :   121..<140,
        "Allegro"       :   140..<160,
        "Vivace"        :   160..<180,
        "Presto"        :   180..<212,
        "Prestissimo"   :   212..<Metronome.maxTempo
    ]
    
    // MARK: - Methods
    
    mutating func setOverlayState(to state: OverlayState) {
        overlayState = state
    }
    
    /// This function opens relevant pickers and closes all of them separate from `overlayState` changes to allow for smooth pickers animations.
    mutating func setPickerState(to state: PickerState) {
        pickerState = state
    }
    
    mutating func setHint(to hint: Hint) {
        self.hint = hint
    }
    
    mutating func showErrorMessage(_ message: ErrorMessage) {
        self.errorMessage = message
    }
    
    mutating func setTempoName(to value: Int) {
        for range in tempoRanges {
            if range.value.contains(value) {
                tempoName = range.key
            }
        }
    }
    
    mutating func shakeTempoField(_ value: Bool = true) {
        isFieldShaking = value
    }
    
    mutating func showLongPressHintIfNeeded() {
        let tapLimit: Int = 1
        let timeLimit: Double = 2.0
        let now: Double = Date.now.timeIntervalSinceReferenceDate
        let timeSinceLastTap: Double = now - tempoFieldLastTapTime
        
        if timeSinceLastTap >= timeLimit {
            tempoFieldTaps = 1
            tempoFieldLastTapTime = now
        }
        
        if tempoFieldTaps >= tapLimit {
            if timeSinceLastTap <= timeLimit {
                setHint(to: .longPress)
                tempoFieldTaps = 0
                tempoFieldLastTapTime = now
            }
        } else {
            tempoFieldTaps += 1
            tempoFieldLastTapTime = now
        }
    }
    
    mutating func prepareAnimationProperties(for element: AnimationElement, inRect rect: CGRect) {
        
        let origin: CGPoint = .init(
            x: rect.midX,
            y: rect.midY)
        
        switch element {
        case .soundPicker:
            animationPositions[.soundTick] = calculatePosition(for: .soundTick)
            animationPositions[.soundHihat] = calculatePosition(for: .soundHihat)
            animationPositions[.soundKick] = calculatePosition(for: .soundKick)
        case .timePicker:
            animationPositions[.timeThreeFourth] = calculatePosition(for: .timeThreeFourth)
            animationPositions[.timeFourFourth] = calculatePosition(for: .timeFourFourth)
            animationPositions[.timeSixEighths] = calculatePosition(for: .timeSixEighths)
        case .playButton:
            animationPositions[.playButton] = calculatePosition(for: .playButton)
        case .tempoText:
            animationPositions[.tempoText] = calculatePosition(for: .tempoText)
        }
        
        animationSizes[element] = rect.width
        
        func calculatePosition(for properties: AnimationProperties) -> CGPoint {
            let x: CGFloat = properties.offset.width
            let y: CGFloat = properties.offset.height
            
            let result: CGPoint = .init(
                x: origin.x + x,
                y: origin.y + y)
            
            return result
        }
    }
    
    mutating func setMainGeometryProxy(to geometryProxy: GeometryProxy) {
        mainGeometryProxy = geometryProxy
        didSetMainGeometryProxy = true
    }
    
    mutating func setScrollItemHeight(basedOn parentHeight: CGFloat) {
        let visileScrollItems: CGFloat = CGFloat(GlobalProperties.Scroll.visibleScrollItems)
        scrollItemHeight = parentHeight / visileScrollItems
    }
    
    mutating func setScrollViewProxy(to proxy: ScrollViewProxy) {
        scrollViewProxy = proxy
    }
    
    mutating func updateScrollView(with value: Int) {
        if isReadyForScrolling {
            isReadyForScrolling = false
        }
        
        guard let scrollProxy = scrollViewProxy else {
            print("No scroll proxy found.")
            return
        }
        
        let centerAlignAdjustment: Int = GlobalProperties.Scroll.visibleScrollItems / 2
        scrollProxy.scrollTo(value - centerAlignAdjustment, anchor: .top)
    }
    
    func getHintOffset() -> CGFloat {
        scrollItemHeight * 6
    }
    
    func safelyUnwrap(position: AnimationProperties) -> CGPoint {
        guard let point = animationPositions[position] else {
            print("Couldn't find play position for \(position).")
            return .zero
        }
        return point
    }
    
    func safelyUnwrap(size element: AnimationElement) -> CGFloat {
        guard let size = animationSizes[element] else {
            print("Couldn't find size for \(element).")
            return .zero
        }
        return size
    }
    
    // MARK: - Nested Types
    
    enum OverlayState {
        case none
        case timePicker
        case soundPicker
        case tempoFieldEditing
    }
    
    enum PickerState {
        case none
        case timeSignature
        case sound
    }
    
    enum Hint {
        case none
        case firstTimeExperience
        case keepTapping
        case longPress
        case volumeOff
        
        var text: String {
            switch self {
            case .none:
                return " "
            case .firstTimeExperience:
                return "Tap or swipe to set tempo"
            case .keepTapping:
                return "Keep tapping..."
            case .longPress:
                return "Long press to edit"
            case .volumeOff:
                return "Turn up the volume"
            }
        }
        
        var symbol: String {
            switch self {
            case .keepTapping:
                "hand.tap.fill"
            case .longPress:
                "dot.circle.and.hand.point.up.left.fill"
            case .volumeOff:
                "speaker.slash.fill"
            default:
                "info.circle.fill"
            }
        }
    }
    
    enum ErrorMessage {
        case none
        case newTempoLessThanMinTempo
        case newTempoMoreThanMaxTempo
        
        var text: String {
            switch self {
            case .none:
                return " "
            case .newTempoLessThanMinTempo:
                return MetronomeError.newTempoLessThanMinTempo.description
            case .newTempoMoreThanMaxTempo:
                return MetronomeError.newTempoMoreThanMaxTempo.description
            }
        }
    }
}
