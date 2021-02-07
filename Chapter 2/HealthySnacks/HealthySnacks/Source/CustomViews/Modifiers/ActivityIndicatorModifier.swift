//
//  ActivityIndicatorModifier.swift
//  HealthySnacks
//
//  Created by Mario Vanegas on 1/21/21.
//

import SwiftUI

struct ActivityIndicatorModifier: ViewModifier {
    var isAnimating: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            ActivityIndicator(isAnimating: isAnimating)
        }
    }
}

extension View {
    func activityIndicator(isAnimating: Bool) -> some View {
        self.modifier(ActivityIndicatorModifier(isAnimating: isAnimating))
    }
}
