//
//  LedViewModel.swift
//  LedController
//
//  Created by Miho Shimizu on 9/15/24.
//

import Foundation

@Observable class LedViewModel {
    private let btManager = BluetoothManager()

    let leds: [Led] = [
        Led(id: 0, name: "LED 1", color: .ledColorRed),
        Led(id: 1, name: "LED 2", color: .ledColorBlue),
        Led(id: 2, name: "LED 3", color: .ledColorGreen),
        Led(id: 3, name: "LED 4", color: .ledColorYellow),
    ]
    var prevSelectedLed: Led?
    var selectedLed: Led?
    
    func toggleLed(selectedLed led: Led) {
        prevSelectedLed = selectedLed
        if let prevLed = prevSelectedLed {
            prevLed.control.ledStateType = .off
            writeLedState(led: prevLed)
            if prevLed == led {
                selectedLed = nil
                return
            }
        }
        selectedLed = led
        led.control.ledStateType = .solid
        writeLedState(led: led)
    }
    
    func writeLedState(led: Led) {
        btManager.putLed(ledId: led.id, state: led.control.ledStateType, color: led.control.ledColorType)
    }
}
