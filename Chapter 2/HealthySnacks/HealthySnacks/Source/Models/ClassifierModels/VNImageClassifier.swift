//
//  VNImageClassifier.swift
//  HealthySnacks
//
//  Created by Mario Vanegas on 1/21/21.
//

import UIKit
import CoreML
import Vision
import Combine
import CombineExt

class VNImageClassifier: ImageClassifierType {
    // MARK: Properties
    private let model: MLModel
    private lazy var classificationRequest: VNCoreMLRequest? = {
        // Intantiate our Vision CoreML Model to perform the request using our model
        guard let visionModel = try? VNCoreMLModel(for: model) else { return nil }
        
        // Create the Vision CoreML Request
        let request = VNCoreMLRequest(model: visionModel, completionHandler: classificationRequestHandler)
        
        // Crop and scale our model to 227x227 px
        request.imageCropAndScaleOption = .centerCrop
        
        return request
    }()
    
    private(set) var classificationPublisher =  PassthroughRelay<ClassificationResult>()
    
    init(with coremlModel: CoreMLModelType) {
        self.model = coremlModel.mlModel
    }
    
    // MARK: Functionality
    func classify(image: UIImage) {
        // Converts UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            classificationPublisher.accept(.failure(ImageClassifierError.IMAGE_CONVERTION_ERROR))
            return
        }
        
        // Makes sure the image is way up
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        // Performs the request in a secondary thread to avoid blocking the main thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Safe unwraps the request
            guard let classificationRequest = self?.classificationRequest else {
                self?.classificationPublisher.accept(.failure(ImageClassifierError.NULL_CLASSIFICATION_REQUEST))
                return
            }
            
            // Instantiate the request handler
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            
            do {
                // Performs the request
                try handler.perform([classificationRequest])
            } catch {
                // Handles error
                self?.classificationPublisher.accept(.failure(error))
            }
        }
    }
    
    private func classificationRequestHandler(_ request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            // Handles error if request fails
            if let error = error {
                self?.classificationPublisher.accept(.failure(error))
                return
            }
            
            // Converts results to VNClassificationObservation Array
            let results = (request.results as? [VNClassificationObservation])?.map { Prediction(label: $0.identifier, confidence: $0.confidence) }
            
            // Publish changes
            self?.classificationPublisher.accept(.success(results ?? []))
        }
    }
}
