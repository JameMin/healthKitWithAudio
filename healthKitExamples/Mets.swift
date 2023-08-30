//
//  Mets.swift
//  healthKitExamples
//
//  Created by 서민영 on 2023/08/28.
//

import Foundation

enum Mets: Double {
    case stationary = 0.0
    case walking = 3.8
    case running = 10.0
    
    func value() -> Double {
        return self.rawValue
    }
}
