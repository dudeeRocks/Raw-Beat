// Abstract: View to show thank you note on complete in-app purchase.

import SwiftUI

struct ThankYouNote: View {
    @Binding var isPresented: Bool
    let tip: Tip
    
    @State private var isSlideUp: Bool = false
    
    private let padding: EdgeInsets = .init(top: 30.0,
                                            leading: 30.0,
                                            bottom: 50.0,
                                            trailing: 30.0)
    
    private var buttonText: LocalizedStringKey {
        switch tip {
        case .water:
            return "M'kay"
        case .coffee:
            return "Back to work!"
        case .beer:
            return "Cheers!"
        }
    }
    
    var body: some View {
        ZStack {
            Color.black // FIXME: Gotta change the color in dark mode
                .opacity(0.75)
                .ignoresSafeArea()
            ZStack {
                VStack(alignment: .center, spacing: 40.0) {
                    // MARK: Emoji and Hearts
                    ZStack {
                        HeartsVisualizer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 70.0, weight: .black))
                            .foregroundStyle(Color.accent)
                            .symbolEffect(.bounce, options: .repeating, isActive: true)
                            .shadow(color: Color.white.opacity(0.5), radius: 5.0, x: 0.0, y: 0.0)
                    }
                    .frame(height: 180.0, alignment: .center)
                    
                    VStack(alignment: .center, spacing: 20.0) {
                        // MARK: Title
                        Text(tip.thankYouNoteContent.title)
                            .font(.title2)
                            .fontWeight(.black)
                        
                        // MARK: Note
                        Text(tip.thankYouNoteContent.description)
                            .fontWeight(.medium)
                    }
                    
                    // MARK: Close button
                    Button {
                        isSlideUp = false
                        withAnimation(.easeOut.delay(0.5)) {
                            isPresented = false
                        }
                    } label: {
                        Text(buttonText)
                            .padding(.horizontal, 20)
                    }
                    .buttonStyle(CustomButton(isOutlined: false, size: .medium, shape: Capsule()))

                }
                .padding(padding)
                .background(Color.gradientStartColor, in: RoundedRectangle(cornerRadius: 24.0))
                .multilineTextAlignment(.center)
                .offset(x: 0.0, y: isPresented ? 0.0 : 100.0)
                .opacity(isPresented ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3), value: isSlideUp)
            }
            .padding()
        }
        .onAppear {
            isSlideUp = true
        }
    }
}
