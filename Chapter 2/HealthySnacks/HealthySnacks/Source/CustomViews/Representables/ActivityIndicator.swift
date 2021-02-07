//
//  ActivityIndicator.swift
//  HealthySnacks
//
//  Created by Mario Vanegas on 1/21/21.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    var isAnimating = false
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.style = .large
        
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
