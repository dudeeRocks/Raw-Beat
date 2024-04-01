//
//  ContentView.swift
//  Raw Beat
//
//  Created by David Katsman on 31/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var metronome: Metronome
    @ObservedObject var hapticsPlayer: HapticsPlayer
    @ObservedObject var touchParticleSystem: TouchPaticleSystem
    @ObservedObject var beatsParticleSystem: BeatsParticleSystem
    @State var sharedData: SharedData = SharedData(overlayState: .none, hint: .firstTimeExperience)
    
    @GestureState var isLongPress: Bool = false
    
    private var isAnyPickerOpen: Bool {
        return sharedData.overlayState != .none
    }
    
    private var isTempoFieldOpen: Bool {
        return sharedData.overlayState == .tempoFieldEditing
    }
    
    private var isTempoFieldPressed: Binding<Bool> {
        return Binding(get: { isLongPress }, set: { _ in })
    }
    
    // MARK: - Gestures
    
    private var tempoTap: some Gesture {
        SpatialTapGesture(coordinateSpace: .global)
            .onEnded { tap in
                handleTap(at: tap.location)
            }
    }
    
    private var tempoFieldLongPress: some Gesture {
        var longPress: some Gesture {
            LongPressGesture(minimumDuration: GlobalProperties.longPressDuration, maximumDistance: 0)
                .updating($isLongPress) { currentState, gestureState, transaction in
                    gestureState = currentState
                    transaction.animation = .easeIn(duration: GlobalProperties.longPressDuration)
                    
                    hapticsPlayer.play(pattern: .longPressUpdating)
                }
                .onEnded { gestureState in
                    withAnimation(Animations.hint) {
                        sharedData.setHint(to: .none)
                    }
                    
                    withAnimation(Animations.buttonBar) {
                        sharedData.setOverlayState(to: .tempoFieldEditing)
                    }
                    
                    hapticsPlayer.play(pattern: .longPressEnded)
                }
        }
        
        var tapForHint: some Gesture {
            SpatialTapGesture(coordinateSpace: .global)
                .onEnded { tap in
                    handleTap(at: tap.location)
                    withAnimation(Animations.hint) {
                        sharedData.showLongPressHintIfNeeded()
                    }
                }
        }
        
        return SimultaneousGesture(tapForHint, longPress)
    }
    
    private var swipeDownToDismissTempoField: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { dragValue in
                let startY: CGFloat = dragValue.startLocation.y
                let endY: CGFloat = dragValue.location.y
                if endY > startY {
                    dismissTempoFieldInput()
                }
            }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            GeometryReader { geometryProxy in
                RadialGradient(colors: [Color.gradientStartColor, Color.gradientEndColor], center: .center, startRadius: 0, endRadius: geometryProxy.size.height / 2)
                .onAppear { sharedData.setMainGeometryProxy(to: geometryProxy) }
            }
            .ignoresSafeArea()
            
            TouchVisualizer(model: touchParticleSystem, sharedData: $sharedData, isLongPress: isTempoFieldPressed)
            BeatsVisualizer(model: beatsParticleSystem, sharedData: $sharedData)
            
            VStack {
                ZStack {
                    Color.clear
                    
                    TempoMarking(sharedData: $sharedData)
                        .accessibilityHidden(true)
                        .accessibilityIdentifier(ViewIdentifiers.tempoMarking.rawValue)
                    
                    TempoScroll(sharedData: $sharedData, onScroll: { hapticsPlayer.play(pattern: .scroll) })
                        .accessibilitySortPriority(-1)
                        .accessibilityIdentifier(ViewIdentifiers.tempoScroll.rawValue)
                    
                    ZStack {
                       
                        if sharedData.overlayState == .tempoFieldEditing {
                            TempoField(sharedData: $sharedData)
                                .fixedSize()
                        } else {
                            TempoText(sharedData: $sharedData, isPressed: isTempoFieldPressed)
                                .fixedSize()
                                .contentShape(.interaction, Circle(), eoFill: true)
                                .accessibilitySortPriority(1)
                                .gesture(isAnyPickerOpen ? nil : tempoFieldLongPress)
                        }
                    }
                    .frame(width: 48, height: 48, alignment: .center)
                    
                    Hint(sharedData: $sharedData)
                        .accessibilityHidden(true)
                }
                .zIndex(-1)
                .background { setScrollItemHeight() }
                
                ButtonBar(sharedData: $sharedData,
                          submit: { setTempo(to: sharedData.newTempo, isFieldSubmit: true) },
                          dismiss: { dismissTempoFieldInput() })
            }
            .foregroundStyle(Color.primaryColor)
        }
        .gesture(isTempoFieldOpen ? swipeDownToDismissTempoField : nil)
        .gesture(tempoTap)
        .environmentObject(metronome)
    }
    
    // MARK: - View Builders
    
    @ViewBuilder private func setScrollItemHeight() -> some View {
        if sharedData.didSetMainGeometryProxy {
            if !sharedData.didMeasureScrollItem {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            sharedData.setScrollItemHeight(basedOn: proxy.size.height)
                            if sharedData.scrollItemHeight != nil {
                                sharedData.didMeasureScrollItem = true
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func setTempo(to value: Int, isFieldSubmit: Bool = false) {
        if isFieldSubmit {
            do {
                try withAnimation(Animations.buttonBar) {
                    try metronome.setTempo(to: value)
                    sharedData.setOverlayState(to: .none)
                }
                withAnimation(Animations.errorMessage) {
                    sharedData.showErrorMessage(.none)
                }
            } catch MetronomeError.newTempoLessThanMinTempo {
                withAnimation(Animations.errorMessage) {
                    sharedData.showErrorMessage(.newTempoLessThanMinTempo)
                }
                sharedData.shakeTempoField()
                hapticsPlayer.defaultFeedbackGenerator?.notificationOccurred(.error)
            } catch MetronomeError.newTempoMoreThanMaxTempo {
                withAnimation(Animations.errorMessage) {
                    sharedData.showErrorMessage(.newTempoMoreThanMaxTempo)
                }
                sharedData.shakeTempoField()
                hapticsPlayer.defaultFeedbackGenerator?.notificationOccurred(.error)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            do {
                try metronome.setTempo(to: value)
            } catch MetronomeError.newTempoLessThanMinTempo {
                metronome.tempo = Metronome.minTempo
            } catch MetronomeError.newTempoMoreThanMaxTempo {
                metronome.tempo = Metronome.maxTempo
            } catch {
                print(error.localizedDescription)
                return
            }
            sharedData.newTempo = metronome.tempo
        }
        
        sharedData.updateScrollView(with: value)
        sharedData.setTempoName(to: value)
    }
    
    private func dismissTempoFieldInput() {
        sharedData.newTempo = sharedData.oldTempo
        withAnimation(Animations.errorMessage) {
            sharedData.showErrorMessage(.none)
        }
        withAnimation(Animations.buttonBar) {
            sharedData.setOverlayState(to: .none)
        }
    }
    
    private func handleTap(at location: CGPoint) {
        switch sharedData.overlayState {
        case .none:
            let now: Double = CACurrentMediaTime()
            let tap: Tap = Tap(creationTime: now, location: location)
            
            touchParticleSystem.handle(tap: tap) { result in
                if let calculatedTempo = result {
                    setTempo(to: calculatedTempo)
                } else {
                    withAnimation(Animations.hint) {
                        sharedData.setHint(to: .keepTapping)
                    }
                }
            }
        case .soundPicker, .timePicker:
            closePickers()
        default:
            return
        }
    }
    
    /// Closes any open pickers. Used from closing pickers on tap outside of the picker area.
    private func closePickers() {
        withAnimation(Animations.menuClose) {
            sharedData.setPickerState(to: .none)
        }
        withAnimation(Animations.menuClose.delay(Animations.DurationPreset.min.value)) {
            sharedData.setOverlayState(to: .none)
        }
    }
}
