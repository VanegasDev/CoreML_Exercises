//
//  ImageClassifierType.swift
//  HealthySnacks
//
//  Created by Mario Vanegas on 1/23/21.
//

import UIKit
import CoreML
import Combine
import CombineExt

typealias ClassificationResult = Result<[Prediction], Error>

enum ImageClassifierError {
    case IMAGE_CONVERTION_ERROR
    case NULL_CLASSIFICATION_REQUEST
}

extension ImageClassifierError: Error {
    var localizedDescription: String {
        switch self {
        case .IMAGE_CONVERTION_ERROR:
            return "Error While Converting Image"
        case .NULL_CLASSIFICATION_REQUEST:
            return "There's no Classification Request"
        }
    }
}

protocol ImageClassifierType {
    var classificationPublisher: PassthroughRelay<ClassificationResult> { get }
    func classify(image: UIImage)
}

protocol CoreMLModelType: class {
    var mlModel: MLModel { get }
}
