//
//  NumberFormatter.swift
//  AudioPlayground
//
//  Created by 김지수 on 3/3/25.
//

import Foundation

public protocol NumberFormattable { }

public extension NumberFormattable {

    /**
    세 자리마다 comma를 붙이고 소수점을 지정한 자릿수까지 표시합니다.
    - parameter point: 소수점 자릿수
    */
    func numberFormatted(with point: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.roundingMode = .halfUp
        formatter.maximumFractionDigits = point
        return formatter.string(from: self as? NSNumber ?? 0) ?? "0"
    }
}

extension Int: NumberFormattable {}
extension Double: NumberFormattable {}
extension Float: NumberFormattable {}
