//
//  CoreMLHealthySnacksClassifier.swift
//  HealthySnacks
//
//  Created by Mario Vanegas on 1/24/21.
//

import UIKit
import Combine
import CombineExt
import CoreML
import Vision

class CoreMLHealthySnacksClassifier: ImageClassifierType {
    // MARK: Properties
    private let model: HealthySnacks
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var classificationPublisher = PassthroughRelay<ClassificationResult>()
    
    init(with model: HealthySnacks) {
        self.model = model
    }
    
    // MARK: Functionality
    func classify(image: UIImage) {
        // Dispatch request in a secondary thread to avoid blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Scales image to 227x227
            guard let pixelBuffer = self?.pixelBuffer(from: image) else {
                self?.classificationPublisher.accept(.failure(ImageClassifierError.IMAGE_CONVERTION_ERROR))
                return
            }
            
            do {
                // Performs prediction request
                let request = try self?.model.prediction(image: pixelBuffer)
                
                // Sorts received predictions and gets the one with more confidence
                let predictions = self?.top(1, request?.labelProbability ?? [:])
                
                DispatchQueue.main.async {
                    // Publishes results on main thread
                    self?.classificationPublisher.accept(.success(predictions ?? []))
                }
            } catch {
                // Handles prediction request errors
                self?.classificationPublisher.accept(.failure(error))
            }
        }
    }
    
    private func top(_ prefix: Int, _ probability: [String: Double]) -> [Prediction] {
        let sortedDictionary = probability.sorted { $0.value > $1.value }.prefix(min(prefix, probability.count))
        let predictions = sortedDictionary.map { Prediction(label: $0.key, confidence: Float($0.value)) }
        
        return predictions
    }
    
    private func pixelBuffer(from uiImage: UIImage) -> CVPixelBuffer? {
        // Describes expected image size by model input
        guard let imageConstraint = model.model.modelDescription.inputDescriptionsByName["image"]?.imageConstraint else { return nil }
        guard let cgImage = uiImage.cgImage else { return nil }
        
        // Tells how to crop and scale the image
        let imageOptions: [MLFeatureValue.ImageOption: Any] = [
            .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
        ]
        
        // Return image scaled to the expected input size
        return try? MLFeatureValue(cgImage: cgImage, constraint: imageConstraint, options: imageOptions).imageBufferValue
    }
}
