// Abstract: Custom ScrollView that updates a tempo on scroll.

import SwiftUI

struct TempoScroll: View {
    
    // MARK: Properties
    
    @EnvironmentObject var metronome: Metronome
    @Binding var sharedData: SharedData
    var onScroll: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    private var isDarkMode: Bool { colorScheme == .dark }
    
    @State private var isShowingScroll: Bool = false
    
    @State private var lastScrollTime: Double = 0
    
    private var itemHeight: CGFloat {
        sharedData.scrollItemHeight
    }
    
    private var opacity: Double {
        sharedData.overlayState == .none ? 1.0 : 0.0
    }
    
    private let range: Range<Int> = {
        let addedSpaces: Int = GlobalProperties.Scroll.visibleScrollItems / 2
        let lowerLimit: Int = Metronome.minTempo - addedSpaces
        let upperLimit: Int = Metronome.maxTempo + addedSpaces
        return lowerLimit..<upperLimit
    }()
    
    private let coordinateSpaceName: String = "tempoScroll"
    
    // MARK: - Body
    
    var body: some View {
        if sharedData.didMeasureScrollItem {
            GeometryReader { geoProxy in
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack(alignment: .center) {
                            LazyVStack(spacing: 0.0) {
                                ForEach(range, id: \.self) { i in
                                    switch i {
                                    case _ where i < Metronome.minTempo || i > Metronome.maxTempo:
                                        createTickMark(proxy: geoProxy)
                                    case let roundNumber where i % 10 == 0:
                                        createTextMark(for: roundNumber, proxy: geoProxy)
                                    default:
                                        createTickMark(proxy: geoProxy)
                                    }
                                }
                            }
                        }
                        .background {
                            GeometryReader { proxy in
                                Color.clear.preference(key: ScrollPosition.self, value: proxy.frame(in: .named(coordinateSpaceName)).origin.y.rounded())
                            }
                        }
                        .modifier(Opacity(state: $isShowingScroll))
                        .onPreferenceChange(ScrollPosition.self) { value in
                            updateScroll(with: value)
                        }
                    }
                    .coordinateSpace(name: coordinateSpaceName)
                    .onAppear {
                        prepareScrollProxy(scrollViewProxy)
                        revealScroll(for: GlobalProperties.fteDuration)
                    }
                    .accessibilityRepresentation {
                        let sliderRange: ClosedRange<Double> = {
                            let min: Double = Double(Metronome.minTempo)
                            let max: Double = Double(Metronome.maxTempo)
                            
                            return min...max
                        }()
                        
                        Slider(value: Binding(get: {
                            Double(metronome.tempo)
                        }, set: { newValue in
                            accessibilityUpdateScroll(with: newValue)
                        }), in: sliderRange)
                        .accessibilityLabel(String(localized: "Tempo slider", comment: "Accessibility label for tempo scroll, which is represented as a slider for VoiceOver."))
                        .accessibilityValue(String(localized:"\(metronome.tempo) beats per minute", comment: "Accessibility value for tempo scroll."))
                    }
                }
            }
            .opacity(opacity)
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder private func createTickMark(proxy: GeometryProxy) -> some View {
        MarkContainer(height: itemHeight, proxy: proxy) {
            Rectangle()
                .frame(width: 32, height: 2, alignment: .center)
                .foregroundStyle(.tertiary)
        }
    }
    
    @ViewBuilder private func createTextMark(for value: Int, proxy: GeometryProxy) -> some View {
        MarkContainer(height: itemHeight, proxy: proxy) {
            Text("\(value)")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.secondary)
                .frame(height: itemHeight)
        }
    }
    
    // MARK: - Methods
    
    private func prepareScrollProxy(_ proxy: ScrollViewProxy) {
        sharedData.scrollViewProxy = proxy
        sharedData.updateScrollView(with: metronome.tempo)
    }
    
    private func updateScroll(with value: CGFloat) {
        if !sharedData.isReadyForScrolling {
            sharedData.isReadyForScrolling = true
            return
        }
        
        revealScroll(for: GlobalProperties.Scroll.timeToHide)
        
        let invertedValue: CGFloat = -value
        let selectedTempo: CGFloat = invertedValue / itemHeight
        let adjustedTempo: Int = Int(selectedTempo) + Metronome.minTempo
        
        if sharedData.oldTempo != adjustedTempo {
            onScroll()
            sharedData.oldTempo = adjustedTempo
            sharedData.newTempo = adjustedTempo
            submitTempo()
            sharedData.setTempoName(to: metronome.tempo)
        }
    }
    
    private func revealScroll(for duration: Double) {
        if !isShowingScroll {
            withAnimation(Animations.scroll) {
                isShowingScroll = true
                hideScrollView(after: duration)
            }
        }
    }
    
    private func submitTempo() {
        do {
            try metronome.setTempo(to: sharedData.newTempo)
        } catch MetronomeError.newTempoLessThanMinTempo {
            metronome.tempo = Metronome.minTempo
        } catch MetronomeError.newTempoMoreThanMaxTempo {
            metronome.tempo = Metronome.maxTempo
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func hideScrollView(after timeLimit: Double) {
        if !isShowingScroll { return }
        
        Task(priority: .userInitiated) {
            try await Task.sleep(for: .seconds(timeLimit))
            
            let now: Double = Date.timeIntervalSinceReferenceDate
            let timeSinceLastUpdate: Double = now - lastScrollTime
            if timeSinceLastUpdate >= timeLimit {
                withAnimation(.easeIn) {
                    isShowingScroll = false
                    lastScrollTime = now
                }
            } else {
                hideScrollView(after: timeLimit)
            }
        }
    }
    
    private func accessibilityUpdateScroll(with value: Double) {
        if !sharedData.isReadyForScrolling {
            sharedData.isReadyForScrolling = true
            return
        }
        
        revealScroll(for: GlobalProperties.Scroll.timeToHide)
        
        let convertedValue: Int = Int(value)
        
        onScroll()
        sharedData.oldTempo = convertedValue
        sharedData.newTempo = convertedValue
        submitTempo()
        sharedData.setTempoName(to: metronome.tempo)
        withAnimation(Animations.scroll) {
            sharedData.updateScrollView(with: convertedValue)
        }
    }
    
    // MARK: - Nested Types
    
    struct MarkContainer<Content: View>: View {
        
        var height: CGFloat
        var proxy: GeometryProxy
        @ViewBuilder var content: () -> Content
        
        var maxY: CGFloat!
        var minY: CGFloat!
        var midY: CGFloat!
        
        init(height: CGFloat, proxy: GeometryProxy, content: @escaping () -> Content) {
            self.height = height
            self.proxy = proxy
            self.content = content
            
            self.maxY = proxy.frame(in: .global).maxY
            self.minY = proxy.frame(in: .global).minY
            self.midY = proxy.frame(in: .global).midY
        }
        
        var body: some View {
            GeometryReader { markContainerGeometry in
                ZStack(alignment: .center) {
                    Color.clear
                    content()
                        .modifier(ScrollEffect(maxY: maxY, minY: minY, midY: midY, geometry: markContainerGeometry))
                }
            }
            .frame(height: height)
        }
    }
    
    struct ScrollEffect: ViewModifier {
        
        var maxY: CGFloat
        var minY: CGFloat
        var midY: CGFloat
        var geometry: GeometryProxy
        
        func body(content: Content) -> some View {
            let posY: CGFloat = geometry.frame(in: .global).midY
            
            var value: CGFloat
            
            if posY < midY {
                value = (posY - minY) / (midY - minY)
            } else {
                value = (posY - maxY) / (midY - maxY)
            }
            
            if value <= 0.0 { value = 0.01 }
            
            return content
                .scaleEffect(value)
                .opacity(value)
        }
    }
    
    struct Opacity: ViewModifier {
        @Binding var state: Bool
        
        func body(content: Content) -> some View {
            content
                .opacity(state ? 1.0 : 0.0)
        }
    }
    
    struct ScrollPosition: PreferenceKey {
        typealias Value = CGFloat
        static var defaultValue: CGFloat = .zero
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            // reduce method was not implemented
        }
    }
}
