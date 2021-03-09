//
//  BLEManager.swift
//  CasperGlowPro
//
//  Created by Jeffrey Deng on 2021-02-01.
//

import Foundation
import CoreBluetooth

protocol BLEManagerDelegate: class {
    func didConnectGlowPeripheral(_ peripheral: CBPeripheral)
}

class BLEManager: NSObject {
    static let shared = BLEManager()
    var glowPeripheral: CBPeripheral?
    
    weak var delegate: BLEManagerDelegate?

    private var centralManager: CBCentralManager!
    

    init(delegate: BLEManagerDelegate? = nil) {
        super.init()
        self.delegate = delegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}


// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            fatalError()
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        
        if peripheral.identifier == UUID(uuidString: "05FCC8E5-39F5-DB12-939D-95155D24CE79") {
            glowPeripheral = peripheral
            print(advertisementData)
            central.connect(peripheral, options: nil)
            central.stopScan()
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            GlowLogger.logError(error)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.didConnectGlowPeripheral(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            GlowLogger.logError(error)
        }
    }
}
