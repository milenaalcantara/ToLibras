//
//  ContentView.swift
//  ToLibras
//
//  Created by Milena Lima de Alcântara on 11/05/23.
//

import SwiftUI
import CoreML

struct ContentView: View {
    let model = ToLibras_HandPoses()
    
    @State var changeImage = false
    @State var openSheet = false
    @State var openCamera = false
//    @State var openPhotos = false
    @State var isPresentedDialog = false
    @State var imageSelected = UIImage()
    private var imageWidthSize: CGFloat = UIScreen.main.bounds.width * 0.9
    
    @State private var classificationLabel: String = ""
    
    var body: some View {
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
                        classificationLabel = ""
                        openSheet = true
                        openCamera = true
                        changeImage = true
                    } label: {
                        Text("Abrir a câmera")
                    }
                    
                    Button {
                        classificationLabel = ""
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
                // task para setar false depois, todas as bools
            
            Button("Classificar") {
                classifyImage(imageSelected)
            }
            .frame(width: imageWidthSize * 0.92)
            .padding()
            .foregroundColor(Color.white)
            .background(Color.green)
            .cornerRadius(9)
            
            Text("\(classificationLabel)")
                .padding()
                .font(.body)

            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $openSheet) {
            if openCamera {
                ImagePicker(selectedImage: $imageSelected, sourceType: .camera)
            } else {
                ImagePicker(selectedImage: $imageSelected, sourceType: .photoLibrary)
            }
            
        }
    }
    
    private func classifyImage(_ image: UIImage) {
        // 1
        guard let pose = preprocess(image: imageSelected) else {
            return
        }

        // 3
        let output = try? model.prediction(poses: pose)
        
        if let output = output {
            let label = output.label
            print(label)
            self.classificationLabel = label
        }
        
//        let output = try? model.prediction(image: buffer)
//
//        if let output = output {
//            let results = output.classLabelProbs.sorted { $0.1 > $1.1 }
//            let result = results.map { (key, value) in
//                return "\(key) = \(String(format: "%.2f", value * 100))%"
//            }.joined(separator: "\n")
//
//            self.classificationLabel = result
//        }
    }
    
    func preprocess(image: UIImage) -> MLMultiArray? {
        let size = CGSize(width: 3, height: 21)
        
        
        guard let pixels = image.resize(to: size).pixelData()?.map({ (Double($0) / 255.0 - 0.5) * 2 }) else {
            return nil
        }
        
        guard let array = try? MLMultiArray(shape: [1, 3, 21], dataType: .double) else {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
