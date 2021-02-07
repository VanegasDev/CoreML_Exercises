//
//  ImageClassifierViewController.swift
//  HealthySnacks
//
//  Created by Mario Vanegas on 1/20/21.
//

import SwiftUI
import Combine
import CombineExt
import CoreML

class ImageClassifierViewController: UIViewController {
    // MARK: Properties
    private let viewModel: ImageClassifierViewModel
    private let binaryClassifier: ImageClassifierType
    private let multiClassifier: ImageClassifierType
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ImageClassifierViewModel = ImageClassifierViewModel(),
         binaryClassifier: ImageClassifierType = CoreMLHealthySnacksClassifier(with: HealthySnacks()),
         multiClassifier: ImageClassifierType = VNImageClassifier(with: SqueezeNet())) {
        self.viewModel = viewModel
        self.binaryClassifier = binaryClassifier
        self.multiClassifier = multiClassifier
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) hasn't been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Image Classifier"
        
        setupBindings()
        addHosting(view: ImageClassifierView(viewModel: viewModel))
    }
    
    // MARK: Setup
    private func setupBindings() {
        let picturePublisher = viewModel.takePicturePublisher.receive(on: DispatchQueue.main)
        let libraryPublisher = viewModel.chooseFromLibraryPublisher.receive(on: DispatchQueue.main)
        let binaryPredictionPublisher = binaryClassifier.classificationPublisher.receive(on: DispatchQueue.main)
        let multiPredictionPublisher = multiClassifier.classificationPublisher.receive(on: DispatchQueue.main)
        
        picturePublisher.sink { [weak self] in self?.choosePicture(from: .camera) }.store(in: &cancellables)
        libraryPublisher.sink { [weak self] in self?.choosePicture(from: .photoLibrary) }.store(in: &cancellables)
        binaryPredictionPublisher.sink { [weak self] predictionResult in
            switch predictionResult {
            case .success(let predictions): self?.viewModel.showReceived(predictions, error: nil)
            case .failure(let error): self?.viewModel.showReceived(error: error)
            }
        }
        .store(in: &cancellables)
        multiPredictionPublisher.sink { [weak self] predictionResult in
            switch predictionResult {
            case .success(let predictions): self?.viewModel.showReceived(predictions, error: nil)
            case .failure(let error): self?.viewModel.showReceived(error: error)
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: Functionality
    private func choosePicture(from source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        
        present(picker, animated: true, completion: nil)
    }
}

// MARK: Extensions
extension ImageClassifierViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // Receives Image
        guard let image = info[.originalImage] as? UIImage else { return }
        
        // Shows Image to user and performs request
        viewModel.updateChosen(uiImage: image)
        
        // Choose Classifier Type
        switch viewModel.classificationType {
        case .binary: binaryClassifier.classify(image: image)
        case .multiple: multiClassifier.classify(image: image)
        }
    }
}

extension MultiSnacks: CoreMLModelType {
    var mlModel: MLModel {
        model
    }
}

extension HealthySnacks: CoreMLModelType {
    var mlModel: MLModel {
        model
    }
}

extension SqueezeNet: CoreMLModelType {
    var mlModel: MLModel {
        model
    }
}
