//
//  LedModel.swift
//  LedController
//
//  Created by Miho Shimizu on 8/24/24.
//

import Foundation
import SwiftUI

struct LedConstants {
    static let ledUnitNum: Int = 10
}

enum LedColor: UInt8 {
    case off = 0
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
    
    func toColor() -> Color {
        switch self {
        case .off:
            return .black
        case .red:
            return .red
        case .green:
            return .green
        case .yellow:
            return .yellow
        case .blue:
            return .blue
        case .magenta:
            return .pink
        case .cyan:
            return .cyan
        case .white:
            return .white
        }
    }
}

enum LedState: UInt8 {
    case off = 0
    case solid
    case blink
}

struct LedControl {
    var state: LedState
    var color: LedColor
    
    func toData() -> Data {
        var data = Data()
        
        var colorRaw: UInt8 = 0
        var stateRaw = state.rawValue
        
        data.append(&stateRaw, count: 1)
        data.append(&colorRaw, count: 1)

        return data
    }
    
//    func fromData(data: Data) -> LedControl {
//        
//    }
}

class Led: Identifiable {
    let name: String
    var control: LedControl
    var id: String { name }
    
    init(name: String, color: LedColor) {
        self.name = name
        self.control = LedControl(state: .off, color: color)
    }
    
    static func == (lhs: Led, rhs: Led) -> Bool {
        return lhs.id == rhs.id
    }
}
