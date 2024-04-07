//
//  ErrorMessage.swift
//  Metronome
//
//  Created by David Katsman on 06/03/2024.
//

import SwiftUI

struct ErrorMessage: View {
    
    @Binding var sharedData: SharedData
    
    @AccessibilityFocusState private var isAccessibilityFocused: Bool
    
    private var isErrorShown: Bool {
        sharedData.errorMessage != .none
    }
    
    private var offsetY: CGFloat {
        sharedData.scrollItemHeight * 5
    }
    
    private var errorMessageTextView: some View {
        Text(sharedData.errorMessage.text)
            .accessibilityLabel(String(localized: "Tempo input error: \(sharedData.errorMessage.text)", comment: "Error message accessibility label."))
            .accessibilityFocused($isAccessibilityFocused)
            .accessibilityIdentifier(ViewIdentifiers.errorMessage.rawValue)
            .onAppear {
                isAccessibilityFocused = true
            }
    }
    
    var body: some View {
        if isErrorShown {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .accessibilityHidden(true)
                switch sharedData.errorMessage {
                case .newTempoMoreThanMaxTempo:
                    errorMessageTextView
                default:
                    errorMessageTextView
                }
            }
            .modifier(ErrorMessageStyle())
            .offset(x: 0.0, y: offsetY)
        }
    }
    
    // MARK: Nested Types
    
    struct ErrorMessageStyle: ViewModifier {
        
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        
        private var size: Double {
            horizontalSizeClass == .compact ? 16.0 : 24.0
        }
        
        func body(content: Content) -> some View {
            content
                .font(.system(size: size, weight: .medium, design: .default))
                .foregroundStyle(Color.label)
                .padding(.vertical, size * 0.5)
                .padding(.horizontal, size * 0.75)
                .background(Color.accentColor, in: Capsule())
        }
    }
}
