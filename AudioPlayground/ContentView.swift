//
//  ContentView.swift
//  AudioPlayground
//
//  Created by 김지수 on 2/11/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var audioManager = AudioManager.shared
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Slider(
                value: $audioManager.singleEQParameter.frequency,
                in: 1000...16000,
                step: 1
            )
                .padding()
            Text("Frequency: \(Int(audioManager.singleEQParameter.frequency)) Hz")
                .font(.headline)
        }
        .padding()
        .onAppear {
            AudioManager.shared.startPinkNoise()
        }
    }
}

#Preview {
    ContentView()
}
