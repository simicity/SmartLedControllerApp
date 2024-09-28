//
//  LedViewModel.swift
//  LedController
//
//  Created by Miho Shimizu on 9/15/24.
//

import Foundation

@Observable class LedViewModel {
    private let btManager = BluetoothManager()

    private let characteristicUUIDString = "9c85a726-b7f1-11ec-b909-0242ac120002"

    let leds: [Led] = [
        Led(name: "Button 1", color: LedColor.red),
        Led(name: "Button 2", color: LedColor.blue),
        Led(name: "Button 3", color: LedColor.green),
        Led(name: "Button 4", color: LedColor.yellow),
    ]
    var selectedLed: Led?

    func updateLedStates() {
        writeLedState()
    }
    
    func writeLedState() {
        var data = Data()
        if let led = selectedLed {
            for i in 0..<LedConstants.ledUnitNum {
                if i < leds.count && leds[i] == led {
                    data.append(led.control.toData())
                } else {
                    data.append(LedControl(state: LedState.off, color: LedColor.off).toData())
                }
            }
        } else {
            for _ in 0..<LedConstants.ledUnitNum {
                data.append(LedControl(state: LedState.off, color: LedColor.off).toData())
            }
        }
        print(data.map { String(format: "%02X ", $0) }.joined())
        btManager.writeDataToCharacteristic(data, uuidString: characteristicUUIDString)
    }
}
