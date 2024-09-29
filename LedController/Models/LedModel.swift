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

class Led: Identifiable {
    let id: UInt32
    let name: String
    var control: LedControl
    
    init(id: UInt32, name: String, color: LedColorType) {
        self.id = id
        self.name = name
        self.control = LedControl()
        self.control.ledStateType = .off
        self.control.ledColorType = color
    }
    
    static func == (lhs: Led, rhs: Led) -> Bool {
        return lhs.id == rhs.id
    }
    
    func ledColorTypeToColor() -> Color {
        switch self.control.ledColorType {
        case .ledColorOff:
            return .black
        case .ledColorRed:
            return .red
        case .ledColorGreen:
            return .green
        case .ledColorYellow:
            return .yellow
        case .ledColorBlue:
            return .blue
        case .ledColorMagenta:
            return .pink
        case .ledColorCyan:
            return .cyan
        case .ledColorWhite:
            return .white
        default:
            return .black
        }
    }
}
