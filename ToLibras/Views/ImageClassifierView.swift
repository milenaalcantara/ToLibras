//
//  ImageClassifierView.swift
//  ToLibras
//
//  Created by Milena Lima de Alcântara on 18/05/23.
//

import SwiftUI
import CoreML


struct ImageClassifierView: View {
    
    let model: MobileNetV2 = {
        do {
            let config = MLModelConfiguration()
            return try MobileNetV2(configuration: config)
        } catch {
            fatalError("Couldn't create MobileNetV2")
        }
    }()
    
    let photos = ["pineapple", "strawberry", "lemon"]
    let sizeScreen = UIScreen.main.bounds.size
    
    @State private var currentIndex: Int = 0
    @State private var classificationLabel: String = ""
    @State private var labelsAndProbabilities = [String : Double]()
    @State private var labelsAndProbabilities2 = [Result]()
    
    var body: some View {
        NavigationView {
            VStack {
                
                Image(photos[currentIndex])
                    .resizable()
                    .frame(
                        width: sizeScreen.width * 0.8,
                        height: sizeScreen.width * 0.8
                    )
                    .cornerRadius(9)
                
                HStack {
                    Button {
//                        labelsAndProbabilities = [String : Double]()
                        labelsAndProbabilities2 = []
                        if self.currentIndex > 0 {
                            self.currentIndex-=1
                        } else {
                            self.currentIndex = self.photos.count - 1
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .padding()
                    .frame(width: sizeScreen.width * 0.39)
                    .foregroundColor(Color.white)
                    .background(Color.gray)
                    .cornerRadius(9)
                    
                    Button {
//                        labelsAndProbabilities2 = [String : Double]()
                        labelsAndProbabilities2 = []
                        if self.currentIndex < self.photos.count - 1 {
                            self.currentIndex+=1
                        } else {
                            self.currentIndex = 0
                        }
                    } label: {
                        Image(systemName: "chevron.forward")
                    }
                    .padding()
                    .frame(width: sizeScreen.width * 0.39)
                    .foregroundColor(Color.white)
                    .background(Color.gray)
                    .cornerRadius(9)
                }
                
                // The button we will use to classify the image using our model
                Button("Classify") {
                    classifyImage()
                }
                .padding()
                .frame(width: sizeScreen.width * 0.8)
                .foregroundColor(Color.white)
                .background(Color.green)
                .cornerRadius(9)
                
                
                
                // The Text View that we will use to display the results of the classification
//                Text("\(classificationLabel)")
//                    .padding()
//                    .font(.body)
                
                List {
                    ForEach(labelsAndProbabilities.sorted(by: { $0.1 > $1.1 } ), id: \.key) { (key, value) in
                        Text("\(key.description.capitalized): \(String(format: "%.2f", value))%")
                    }
                }
                
//                Table(labelsAndProbabilities2) {
//                    TableColumn("Letter", value: \.key)
//                        .width(sizeScreen.width * 0.6)
//                    TableColumn("Probability", value: \.value)
//                        .width(sizeScreen.width * 0.2)
//                }
                
                Spacer()
            }
            .navigationTitle("Image Classifier")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func classifyImage() {
        // 1
        let currentImageName = photos[currentIndex]
        
        // 2
        guard let image = UIImage(named: currentImageName),
              let buffer = image.resize(
                to: CGSize(width: 224, height: 224)
              ).convertToBuffer() else { return }

        // 3
        let output = try? model.prediction(image: buffer)
        
        if let output = output {
            let results = output.classLabelProbs.sorted { $0.1 > $1.1 }
            for result in results {
                labelsAndProbabilities[result.key] = result.value * 100
                labelsAndProbabilities2.append(
                    Result(
                        key: result.key,
                        value: "\(String(format: "%.2f", result.value * 100))%"
                    )
                )
            }
        }
    }
}

struct ImageClassifierView_Previews: PreviewProvider {
    static var previews: some View {
        ImageClassifierView()
    }
}
