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
            .accessibilityLabel("Tempo input error: " + sharedData.errorMessage.text)
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
        func body(content: Content) -> some View {
            content
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(Color.label)
                .padding(.vertical, 6.0)
                .padding(.horizontal, 12.0)
                .background(Color.accentColor, in: Capsule())
        }
    }
}
