//
//  ImageClassifierViewModel.swift
//  HealthySnacks
//
//  Created by Mario Vanegas on 1/21/21.
//

import SwiftUI
import Combine
import CombineExt

enum ClassifierType {
    case binary
    case multiple
}

class ImageClassifierViewModel: ObservableObject {
    // MARK: Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Input
    var takePictureTap = PassthroughRelay<Void>()
    var chooseFromLibraryTap = PassthroughRelay<Void>()
    
    // MARK: Output
    @Published var results: String = ""
    @Published var isShowingActivityIndicator = false
    @Published var classificationType: ClassifierType = .binary
    @Published var image: UIImage?
    
    var takePicturePublisher = PassthroughRelay<Void>()
    var chooseFromLibraryPublisher = PassthroughRelay<Void>()
    
    init() {
        setupBindings()
    }
    
    // MARK: Functionality
    func updateChosen(uiImage: UIImage) {
        image = uiImage
        isShowingActivityIndicator = true
    }
    
    func showReceived(_ predictions: [Prediction] = [], error: Error?) {
        if let error = error {
            results = "Prediction Error: \(error.localizedDescription)"
            return
        }
        
        switch classificationType {
        case .binary:
            guard let prediction = predictions.first else {
                results = "There's no prediction"
                return
            }
            
            results = prediction.confidence < 0.8 ? "Not Sure!" : String(format: "%@ %.1f%%", prediction.label, prediction.confidence * 100)
        case .multiple:
            let top3 = predictions.prefix(3).map { String(format: "%@ %.1f%%", $0.label, $0.confidence * 100) }
            results = top3.isEmpty ? "There's no prediction" : top3.joined(separator: "\n")
        }
        
        
        isShowingActivityIndicator = false
    }
    
    // MARK: Setup
    private func setupBindings() {
        let pictureTap = takePictureTap
        let libraryTap = chooseFromLibraryTap
        
        pictureTap.sink { [weak self] in self?.takePicturePublisher.accept(()) }.store(in: &cancellables)
        libraryTap.sink { [weak self] in self?.chooseFromLibraryPublisher.accept(()) }.store(in: &cancellables)
    }
}
