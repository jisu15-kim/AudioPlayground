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
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Toggle(
                        "OSC",
                        isOn: $audioManager.enableOSC
                    )
                    
                    oscControlView
                    
                    Divider()
                    
                    Toggle(
                        "Pink Noise",
                        isOn: $audioManager.enableNoise
                    )
                    
                    ForEach(0 ..< audioManager.eqParameters.count, id: \.self) { index in
                        EQChannelView(index: index)
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Audio Playground - EQ")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            AudioManager.shared.start()
        }
    }
    
    @ViewBuilder
    var oscControlView: some View {
        VStack {
            HStack {
                VStack {
                    Text("OSC Freq")
                    Text("\(audioManager.oscParameter.frequency.numberFormatted(with: 0)) Hz")
                }
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .frame(width: 60)
                
                Slider(
                    value: $audioManager.oscParameter.frequency,
                    in: 20...13000,
                    step: 1
                )
                .padding()
                .padding(.horizontal, 8)
            }
            
            HStack {
                VStack {
                    Text("OSC Gain")
                    Text("\(audioManager.oscParameter.gain.numberFormatted(with: 1)) db")
                }
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .frame(width: 60)
                
                Slider(
                    value: $audioManager.oscParameter.gain,
                    in: 0.0...3.0,
                    step: 0.1
                )
                .padding()
                .padding(.horizontal, 8)
                
                Menu {
                    ForEach(OSCParameter.OSCType.allCases, id: \.self) { type in
                        Button(type.displayName) {
                            audioManager.oscParameter.type = type
                        }
                    }
                } label: {
                    HStack {
                        Text(audioManager.oscParameter.type.displayName)
                        Image(systemName: "chevron.down")
                    }
                }
            }
        }
        .padding(.all, 8)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2))
        }
    }
    
    @ViewBuilder
    func EQChannelView(index: Int) -> some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .center, spacing: 4) {
                    Text("FREQ")
                        .font(.system(size: 12, weight: .medium))
                    Text("\(audioManager.eqParameters[index].frequency.numberFormatted(with: 0)) Hz")
                        .font(.system(size: 12, weight: .medium))
                }
                .multilineTextAlignment(.center)
                .frame(width: 60)
                
                Slider(
                    value: $audioManager.eqParameters[index].frequency,
                    in: 20...10000,
                    step: 1
                )
                .padding()
                .padding(.horizontal, 8)
            }
            
            HStack {
                VStack(alignment: .center, spacing: 4) {
                    Text("Q")
                        .font(.system(size: 12, weight: .medium))
                    Text("\(audioManager.eqParameters[index].q.numberFormatted(with: 1))")
                        .font(.system(size: 12, weight: .medium))
                }
                .multilineTextAlignment(.center)
                .frame(width: 60)
                
                Slider(
                    value: $audioManager.eqParameters[index].q,
                    in: 0.1...20,
                    step: 0.1
                )
                .padding()
            }
            
            HStack {
                VStack(alignment: .center, spacing: 4) {
                    Text("GAIN")
                        .font(.system(size: 12, weight: .medium))
                    Text("\(audioManager.eqParameters[index].gain.numberFormatted(with: 1)) db")
                        .font(.system(size: 12, weight: .medium))
                }
                .multilineTextAlignment(.center)
                .frame(width: 60)
                
                Slider(
                    value: $audioManager.eqParameters[index].gain,
                    in: -20...20,
                    step: 0.1
                )
                .padding()
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
        }
    }
}

#Preview {
    ContentView()
}
