//
//  AudioManager.swift
//  AudioPlayground
//
//  Created by 김지수 on 2/24/25.
//

import Foundation
import AudioKit
import AudioKitEX
import SoundpipeAudioKit

//MARK: - Parameter
struct EQParameter: Identifiable {
    var id: UUID = UUID()
    var frequency: Float
    var q: Float
    var gain: Float
}

struct OSCParameter: Identifiable {
    var id: UUID = UUID()
    var frequency: Float
    var gain: Float
    var type: OSCType
    
    enum OSCType: String, CaseIterable {
        case sine
        case sawtooth
        case triangle
        case square
        
        var displayName: String {
            switch self {
            case .sine: "Sine"
            case .sawtooth: "Saw"
            case .triangle: "Tri"
            case .square: "Sqr"
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        frequency: Float = 440,
        gain: Float = 0.5,
        type: OSCType = .sine
    ) {
        self.id = id
        self.frequency = frequency
        self.gain = gain
        self.type = type
    }
}

//MARK: - AudioManager
class AudioManager: ObservableObject {
    //MARK: - Instance
    static let shared = AudioManager()
    private init() {}
    
    //MARK: - Properties
    private let engine = AudioEngine()
    
    @Published public var oscParameter = OSCParameter() {
        didSet {
            didSetOSCParameter()
        }
    }
    @Published public var eqParameters: [EQParameter] = {
        let eqParameter = EQParameter(
            frequency: 5000,
            q: 0.5,
            gain: 0
        )
        return Array(repeating: eqParameter,count: 10)
    }() {
        didSet {
            didSetEQParameter()
        }
    }
    
    @Published var enableOSC: Bool = true {
        didSet {
            switchOSC()
        }
    }
    
    @Published var enableNoise: Bool = true {
        didSet {
            switchNoise()
        }
    }
    
    private let inputMixer = Mixer()
    
    private lazy var EQChainGroup: [ParametricEQ] = {
        var eqArray = [ParametricEQ]()
        eqParameters.enumerated().forEach { (index, parameter) in
            if index == 0 {
                eqArray.append(ParametricEQ(inputMixer))
            } else {
                eqArray.append(ParametricEQ(eqArray.last!))
            }
        }
        return eqArray
    }()
    
    private var EQChainOutput: Node {
        return EQChainGroup.last!
    }
    
    private lazy var masterFader: Fader = {
        return Fader(EQChainOutput)
    }()
    
    private var pinkNoise: PinkNoise?
    private let osc = DynamicOscillator()
    
    public func start() {
        let pinkNoise = PinkNoise()
        pinkNoise.amplitude = 0.5
        self.pinkNoise = pinkNoise
        
        osc.frequency = AUValue(440)
        osc.amplitude = oscParameter.gain
        osc.setWaveform(Table(.sine))
        
        inputMixer.addInput(pinkNoise)
        inputMixer.addInput(osc)
        
        pinkNoise.start()
        osc.start()
        
        engine.output = masterFader
        try? engine.start()
    }
    
    private func didSetEQParameter() {
        eqParameters.enumerated().forEach { (index, parameter) in
            EQChainGroup[index].centerFreq = Float(parameter.frequency)
            EQChainGroup[index].q = parameter.q
            EQChainGroup[index].gain = parameter.gain
        }
    }
    
    private func didSetOSCParameter() {
        osc.frequency = oscParameter.frequency
        osc.amplitude = oscParameter.gain
        
        switch oscParameter.type {
        case .sine:
            osc.setWaveform(Table(.sine))
        case .sawtooth:
            osc.setWaveform(Table(.sawtooth))
        case .triangle:
            osc.setWaveform(Table(.triangle))
        case .square:
            osc.setWaveform(Table(.square))
        }
    }
    
    private func switchNoise() {
        guard let pinkNoise else { return }
        pinkNoise.isStarted ? pinkNoise.stop() : pinkNoise.start()
    }
    
    private func switchOSC() {
        osc.isStarted ? osc.stop() : osc.start()
    }
}
