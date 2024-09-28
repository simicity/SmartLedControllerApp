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
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading characteristic value: \(error.localizedDescription)")
            return
        }

        if let data = characteristic.value {
            print("Received data from \(characteristic.uuid): \(data)")
        }
    }
    
    func readDataFromCharacteristics(uuidString: String) {
        guard let peripheral = discoveredPeripheral else { return }
        guard let characteristic: CBCharacteristic = findCharacteristic(by: uuidString) else { return }
        peripheral.readValue(for: characteristic)
    }

    func writeDataToCharacteristic(_ data: Data, uuidString: String) {
        guard let peripheral = discoveredPeripheral else { return }
        guard let characteristic: CBCharacteristic = findCharacteristic(by: uuidString) else { return }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func findCharacteristic(by uuidString: String) -> CBCharacteristic? {
        let characteristicUUID = CBUUID(string: uuidString)
        return discoveredCharacteristics.first { $0.uuid == characteristicUUID }
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
