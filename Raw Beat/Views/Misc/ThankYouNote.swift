// Abstract: View to show thank you note on complete in-app purchase.

import SwiftUI

struct ThankYouNote: View {
    let tip: Tip
    let onDismiss: () -> Void
    
    private let padding: EdgeInsets = .init(top: 30.0,
                                            leading: 30.0,
                                            bottom: 50.0,
                                            trailing: 30.0)
    
    var body: some View {
        ZStack {
            LinearGradient(colors: .gradientStartColor, .gradientEndColor)
                .ignoresSafeArea()
            VStack(alignment: .center, spacing: 20.0) {
                // MARK: Emoji and Hearts
                ZStack {
                    HeartsVisualizer()
                    Image(systemName: "heart.fill")
                        .font(.system(size: 120.0, weight: .black))
                        .foregroundStyle(Color.accent)
                        .symbolEffect(.bounce, options: .repeating, isActive: true)
                        .shadow(color: Color.gradientStartColor, radius: 30.0, x: 0.0, y: 0.0)
                        .accessibilityLabel(String(localized: "Thank you for the tip!", comment: "A11y label on heart image on thank you note."))
                }
                
                VStack(alignment: .center, spacing: 60.0) {
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
                        onDismiss()
                    } label: {
                        Text(String(localized: "Cheers!", comment: "Button text on Thank you note. Closes the note."))
                            .padding(.horizontal, 20)
                    }
                    .buttonStyle(CustomButton(isOutlined: false, size: .medium, shape: Capsule()))
                }
                .padding(padding)
            }
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ThankYouNote(tip: .beer, onDismiss: {})
}
