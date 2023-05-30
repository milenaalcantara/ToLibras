//
//  ContentView.swift
//  ToLibras
//
//  Created by Milena Lima de Alcântara on 11/05/23.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    var body: some View {
        TabView {
            HandPoseClassifierView()
                .tabItem {
                    Label("Hand Pose", systemImage: "hand.raised.circle")
                }
            
            ImageClassifierView()
                .tabItem {
                    Label("Image", systemImage: "photo.circle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
