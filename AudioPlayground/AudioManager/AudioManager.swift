//
//  AudioManager.swift
//  AudioPlayground
//
//  Created by 김지수 on 2/24/25.
//

import Foundation
import AudioKit
import AVFAudio

class AudioManager: ObservableObject {
    //MARK: - Singleton
    static let shared = AudioManager()
    private init() {}
    
    //MARK: - Properties
    let audioEngine = AudioEngine()
    var mixer = Mixer()
    lazy var eqNode = AVAudioUnitEQ()
    var engine: AVAudioEngine {
        return audioEngine.avEngine
    }
    
    class EQParameter {
        @Published var type: AVAudioUnitEQFilterType
        @Published var bandWidth: Float?
        @Published var frequency: Float
        @Published var gain: Float
        
        init(
            type: AVAudioUnitEQFilterType,
            bandWidth: Float? = nil,
            frequency: Float,
            gain: Float
        ) {
            self.type = type
            self.bandWidth = bandWidth
            self.frequency = frequency
            self.gain = gain
        }
    }
    
    @Published var singleEQParameter = EQParameter(
        type: .parametric,
        bandWidth: 1.0,
        frequency: 8000.0,
        gain: 20.0
    )
    private var eqParameters: [EQParameter] {
        return [singleEQParameter]
    }
    
    //  10-Bands Parametric EQ
//    private var eqParameters: [EQParameter] = [
//        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 32.0, gain: 3.0),
//        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 64.0, gain: 3.0),
//        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 128.0, gain: 3.0),
//        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 256.0, gain: 2.0),
//        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 500.0, gain: 0.0),
//        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 1000.0, gain: -20.0),
//        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 2000.0, gain: -6.0),
//        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 4000.0, gain: 10.0),
//        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 8000.0, gain: 20.0),
//        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 13000.0, gain: 12.0)
//    ]
    
    //MARK: - Sources
    var pinkNoise: PinkNoise?
    
    //MARK: - Methods
    func setupEQ() {
        self.eqNode = AVAudioUnitEQ(numberOfBands: self.eqParameters.count)
        self.eqNode.bands.enumerated().forEach { index, param in
            param.filterType = self.eqParameters[index].type
            param.bypass = false
            if let bandWidth = self.eqParameters[index].bandWidth {
                param.bandwidth = bandWidth
            }
            param.frequency = self.eqParameters[index].frequency
            param.gain = self.eqParameters[index].gain
        }
        engine.attach(self.eqNode)
    }
    
    func startPinkNoise() {
        setupEQ()
        
        let pinkNoise = PinkNoise()
        pinkNoise.amplitude = 0.5
        pinkNoise.start()
        
        
        mixer.addInput(pinkNoise)
        
        audioEngine.output = mixer
        
        self.pinkNoise = pinkNoise
        
        try? engine.start()
    }
}
