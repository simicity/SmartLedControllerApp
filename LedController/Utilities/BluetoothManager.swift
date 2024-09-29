//
//  BluetoothManager.swift
//  LedController
//
//  Created by Miho Shimizu on 8/24/24.
//

import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BluetoothManager()

    var isBluetoothEnabled = false

    private var centralManager: CBCentralManager!
    private var discoveredPeripheral: CBPeripheral?
    private var discoveredServices = [CBService]()
    private var discoveredCharacteristics = [CBCharacteristic]()

    private let serviceUUID = CBUUID(string: "f7547938-68ba-11ec-90d6-0242ac120003")
    private let getLedcharacteristicUUID = CBUUID(string: "9c85a726-b7f1-11ec-b909-0242ac120002")
    private let putLedcharacteristicUUID = CBUUID(string: "9c85a726-b7f1-11ec-b909-0242ac120003")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isBluetoothEnabled = true
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            isBluetoothEnabled = false
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        centralManager.stopScan()

        discoveredPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")

        peripheral.delegate = self
        peripheral.discoverServices(nil) // Discover all services
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error reading characteristic value: \(error.localizedDescription)")
            return
        }

        guard let services = peripheral.services else { return }
        discoveredServices = services
        print("Discovered Services: \(services)")
        for service in services {
            print("Service UUID: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service) // Discover characteristics for each service
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error reading characteristic value: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else { return }
        discoveredCharacteristics += characteristics
        print("Discovered Characteristics for Service \(service.uuid): \(characteristics)")
        
        for characteristic in characteristics {
            print("Characteristic UUID: \(characteristic.uuid)")
            // Enable notifications for the characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("Failed to subscribe to notifications: \(error!)")
            return
        }
        if characteristic.isNotifying {
            print("Successfully subscribed to notifications for characteristic: \(characteristic.uuid)")
        } else {
            print("Unsubscribed from notifications for characteristic: \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading characteristic value: \(error.localizedDescription)")
            return
        }

        switch characteristic.uuid {
        case getLedcharacteristicUUID:
            guard let data = characteristic.value else { return }
            do {
                let response = try GetLedResponse(serializedBytes: data)
//                print("LED (ID: \(response.ledID)) State: \(response.ledControl.ledStateType)")
//                print("LED (ID: \(response.ledID)) Color: \(response.ledControl.ledColorType)")
            } catch {
                print("Error deserializing GetLedResponse: \(error)")
            }
        case putLedcharacteristicUUID:
            guard let data = characteristic.value else { return }
            do {
                let response = try PutLedResponse(serializedBytes: data)
//                print("LED (ID: \(response.ledID)) State: \(response.ledControl.ledStateType)")
//                print("LED (ID: \(response.ledID)) Color: \(response.ledControl.ledColorType)")
            } catch {
                print("Error deserializing PutLedResponse: \(error)")
            }
        default:
            break
        }
        
    }

    func getLed(ledId: UInt32) {
        guard let peripheral = discoveredPeripheral else { return }
        guard let characteristic: CBCharacteristic = findCharacteristic(by: getLedcharacteristicUUID) else { return }
        
        var getLedRequest = GetLedRequest()
        getLedRequest.ledID = ledId

        do {
            let data: Data = try getLedRequest.serializedBytes()
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        } catch {
            print("Error serializing GetLedRequest: \(error)")
        }
    }
    
    func putLed(ledId: UInt32, state: LedStateType, color: LedColorType) {
        guard let peripheral = discoveredPeripheral else { return }
        guard let characteristic: CBCharacteristic = findCharacteristic(by: putLedcharacteristicUUID) else { return }

        var putLedRequest = PutLedRequest()
        var ledControl = LedControl()
        ledControl.ledStateType = state
        ledControl.ledColorType = color
        
        putLedRequest.ledID = ledId
        putLedRequest.ledControl = ledControl
        
        do {
            let data: Data = try putLedRequest.serializedBytes()
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        } catch {
            print("Error serializing PutLedRequest: \(error)")
        }
    }
    
    func findCharacteristic(by uuidString: String) -> CBCharacteristic? {
        let characteristicUUID = CBUUID(string: uuidString)
        return discoveredCharacteristics.first { $0.uuid == characteristicUUID }
    }
    
    func findCharacteristic(by uuid: CBUUID) -> CBCharacteristic? {
        return discoveredCharacteristics.first { $0.uuid == uuid }
    }

    func toggleBluetooth() {
        if centralManager.state == .poweredOn {
            centralManager.stopScan()
            centralManager = nil
        } else {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
}
