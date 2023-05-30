//
//  HandPoseClassifierView.swift
//  ToLibras
//
//  Created by Milena Lima de Alcântara on 18/05/23.
//

import SwiftUI
import CoreML

struct Result: Identifiable {
    let id = UUID()
    let key: String
    let value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

struct HandPoseClassifierView: View {
    let model: ToLibras_HandPoses = {
        do {
            let config = MLModelConfiguration()
            return try ToLibras_HandPoses(configuration: config)
        } catch {
            fatalError("Couldn't create ToLibras_HandPoses")
        }
    }()
    
    @State var changeImage = false
    @State var openSheet = false
    @State var openCamera = false
    @State var isPresentedDialog = false
    @State var imageSelected = UIImage()
    private var imageWidthSize: CGFloat = UIScreen.main.bounds.width * 0.9
    
    @State private var labelsAndProbabilities = [String : Double]()
    @State private var labelsAndProbabilities2 = [Result]()
    
    var body: some View {
        NavigationView {
            VStack {
                Button {
                    isPresentedDialog = true
                } label: {
                    ZStack {
                        if changeImage {
                            Image(uiImage: imageSelected)
                                .resizable()
                        } else {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Spacer()
                            
                            Text("Editar")
                                .frame(width: imageWidthSize, height: 40)
                                .background(.gray)
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }
                }
                .frame(width: imageWidthSize, height: imageWidthSize)
                .border(.gray, width: 2)
                .cornerRadius(9)
                .confirmationDialog(
                    "Como você quer adicinar sua imagem?",
                    isPresented: $isPresentedDialog) {
                        Button {
                            labelsAndProbabilities = [String : Double]()
                            openSheet = true
                            openCamera = true
                            changeImage = true
                        } label: {
                            Text("Abrir a câmera")
                        }
                        
                        Button {
                            labelsAndProbabilities = [String : Double]()
                            openCamera = false
                            openSheet = true
                            changeImage = true
                        } label: {
                            Text("Escolher de Fotos")
                        }
                        
                        Button("Cancel", role: .cancel) {
                            isPresentedDialog = false
                            print("Cancel")
                        }
                    }
                
                Button("Classificar") {
                    classifyImage()
                }
                .frame(width: imageWidthSize * 0.92)
                .padding()
                .foregroundColor(Color.white)
                .background(Color.green)
                .cornerRadius(9)
                
                List {
                    ForEach(labelsAndProbabilities.sorted(by: { $0.1 > $1.1 } ), id: \.key) { (key, value) in
                        Text("\(key.description.capitalized): \(String(format: "%.2f", value))%")
                    }
                }
                
//                Table(labelsAndProbabilities2) {
//                    TableColumn("Letter", value: \.key)
//                    TableColumn("Probability", value: \.value)
//                }

                
                Spacer()
            }
            .sheet(isPresented: $openSheet) {
                if openCamera {
                    ImagePicker(selectedImage: $imageSelected, sourceType: .camera)
                } else {
                    ImagePicker(selectedImage: $imageSelected, sourceType: .photoLibrary)
                }
                
            }
            .navigationTitle("Hand Pose Classifier")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func classifyImage() {
        guard let input = preprocess(image: imageSelected) else { return }
        
        let output = try? model.prediction(poses: input)
        
        if let output = output {
            let results = output.labelProbabilities.sorted { $0.1 > $1.1 }
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
    
    func preprocess(image: UIImage) -> MLMultiArray? {
        let size = CGSize(width: 1, height: 7) //
    
        guard let pixels = image.resize(to: size).pixelData()?.map({ (Float($0) / 255.0 - 0.5) * 2 }) else {
            return nil
        }

        guard let array = try? MLMultiArray(shape: [1, 3, 21], dataType: .float32) else {
            return nil
        }

        let r = pixels.enumerated().filter { $0.offset % 4 == 0 }.map { $0.element }
        let g = pixels.enumerated().filter { $0.offset % 4 == 1 }.map { $0.element }
        let b = pixels.enumerated().filter { $0.offset % 4 == 2 }.map { $0.element }

        let combination = r + g + b
        for (index, element) in combination.enumerated() {
            array[index] = NSNumber(value: element)
        }

        return array
    }

}

struct HandPoseClassifierView_Previews: PreviewProvider {
    static var previews: some View {
        HandPoseClassifierView()
    }
}
