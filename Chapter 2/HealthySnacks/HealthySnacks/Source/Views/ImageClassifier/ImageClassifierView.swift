//
//  ImageClassifierView.swift
//  HealthySnacks
//
//  Created by Mario Vanegas on 1/21/21.
//

import SwiftUI

struct ImageClassifierView: View {
    @ObservedObject var viewModel: ImageClassifierViewModel
    
    var body: some View {
        ZStack {
            Image(uiImage: viewModel.image ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                Picker("", selection: $viewModel.classificationType) {
                    Text("Binary Classifier").tag(ClassifierType.binary)
                    Text("Multiclassifier").tag(ClassifierType.multiple)
                }
                .pickerStyle(SegmentedPickerStyle())
                Text(viewModel.results.isEmpty ? "Results" : viewModel.results)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(Color("secondaryColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Spacer()
                HStack {
                    Button(action: viewModel.chooseFromLibraryTap.accept) {
                        Image(systemName: "photo")
                            .frame(width: 55, height: 55)
                            .background(Color("secondaryColor"))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: viewModel.takePictureTap.accept) {
                        Image(systemName: "camera.fill")
                            .frame(width: 55, height: 55)
                            .background(Color("secondaryColor"))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(24)
            .font(.system(size: 22, weight: .semibold))
            .foregroundColor(Color("primaryColor"))
        }
        .activityIndicator(isAnimating: viewModel.isShowingActivityIndicator)
    }
}

struct ImageClassifierView_Previews: PreviewProvider {
    static var previews: some View {
        ImageClassifierView(viewModel: ImageClassifierViewModel())
            .previewDevice(.init(rawValue: "iPhone 11 Pro"))
    }
}
