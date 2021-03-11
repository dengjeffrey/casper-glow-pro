//
//  GlowPeripheralService.swift
//  CasperGlowPro
//
//  Created by Jeffrey Deng on 2021-02-15.
//

import Foundation
import CoreBluetooth

enum GlowCommunicationStatus {
    case notReady
    case searching
    case found
    case waitingForHandshake
    case acknowledgedHandshake
    case sentTime
    case pinged1
    case pinged2
    case ready
    case unsupported
}

class GlowPeripheralService: NSObject {
    weak var delegate: GlowPeripheralServiceDelegate?
    
    private(set) var glowStatus = GlowCommunicationStatus.searching
    private let glowPeripheral: CBPeripheral
    private var glowCharacteristics: GlowCharacteristics!
    private var lastWrite: GlowData.WriteType?
    
    init(glowPeripheral: CBPeripheral, delegate: GlowPeripheralServiceDelegate? = nil) {
        self.glowPeripheral = glowPeripheral
        
        super.init()
        
        self.delegate = delegate
        glowPeripheral.delegate = self
        glowPeripheral.discoverServices(nil)
    }
    
    func turnLightOff() -> GlowError? {
        guard glowStatus == .ready else {
            return GlowError.peripheralNotReady
        }
        writeTurnOffLight()
        return nil
    }
    
    func turnLightOn() -> GlowError? {
        guard glowStatus == .ready else {
            return GlowError.peripheralNotReady
        }
        writeTurnOnLight()
        return nil
    }
}

// MARK: - CBPeripheralDelegate
extension GlowPeripheralService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            GlowLogger.logError(error)
            return
        }
        
        guard let services = peripheral.services,
              let casperService = services.first(where: { $0.uuid == GlowData.SERVICE_UUID })
        else {
            GlowLogger.logError("Unable to find Casper service")
            return
        }

        peripheral.discoverCharacteristics(nil, for: casperService)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            GlowLogger.logError(error)
            return
        }
        
        guard
            let characteristics = service.characteristics,
            let glowCharacteristics = GlowCharacteristics(manyCharacteristics: characteristics)
        else {
            glowStatus = .unsupported
            return
        }
        
        self.glowCharacteristics = glowCharacteristics

        glowStatus = .found
        subscribeToReadyNotification()
        
        // Changing this to writeConnectionHandshake() will require you to press on the Glow.
        // This will cause the Glow to send its device identifier which can be used to configure the packets in the future
        writeReconnectionHandshake()
    }
    
    // Device -> Peripheral
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard .writeChannel == GlowCharacteristicUUID(characteristic: characteristic) else {
            fatalError("Unexpected write to a characteristic that we have not reversed")
        }
        
        if let error = error {
            GlowLogger.logError(error)
            return
        } else if glowStatus == .waitingForHandshake {
            subscribeToReadyNotification()
        }
    }
    
    // Peripheral -> Device
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            GlowLogger.logError(error)
            return
        }
        
        switch lastWrite {
        case .connect, .reconnect:
            if characteristic.value == GlowData.Read.READY_BYTES {
                writeConnectionAcknowledgment()
            } else {
                fatalError("Glow returned unexpected response for connect and reconnect events")
            }
        case .connectAck:
            glowStatus = .ready
            delegate?.peripheralDidChangeToReady()
        case .turnOnLight:
            delegate?.lightStatusDidChange(isLightOn: true)
        case .turnOffLight:
            delegate?.lightStatusDidChange(isLightOn: false)
        default:
            return
        }
    }
}


// MARK: - Writes
extension GlowPeripheralService {
    private func write(_ writeType: GlowData.WriteType) {
        lastWrite = writeType
        glowPeripheral.writeValue(writeType.data, for: glowCharacteristics.writeCharacteristic, type: .withResponse)
    }
    
    
    private func writeReconnectionHandshake() {
        glowStatus = .waitingForHandshake
        write(.reconnect)
    }
    
    private func writeConnectionHandshake() {
        glowStatus = .waitingForHandshake
        write(.connect)
    }
    
    private func writeConnectionAcknowledgment() {
        glowStatus = .acknowledgedHandshake
        write(.connectAck)
    }
    
    private func writeTurnOnLight() {
        write(.turnOnLight)
    }
    
    private func writeTurnOffLight() {
        write(.turnOffLight)
    }
    
    private func writeSendTime() {
        glowStatus = .sentTime
        write(.timeUpdate)
    }
    
    private func writePing1() {
        glowStatus = .pinged1
        write(.ping1)
    }
    
    private func writePing2() {
        glowStatus = .pinged2
        write(.ping2)
    }
}

// MARK: - Subscriptions
extension GlowPeripheralService {
  private func subscribeToReadyNotification() {
        glowPeripheral.setNotifyValue(true, for: glowCharacteristics.readCharacteristic)
    }
}



// MARK: - GlowCharacteristics
private struct GlowCharacteristics {
    private let characteristics: [GlowCharacteristicUUID: CBCharacteristic]
    let writeCharacteristic: CBCharacteristic
    let readCharacteristic: CBCharacteristic
    
    
    init?(manyCharacteristics: [CBCharacteristic]) {
        var characteristicMap = [GlowCharacteristicUUID: CBCharacteristic]()
        for characteristic in manyCharacteristics {
            if let characteristicUUID = GlowCharacteristicUUID(rawValue: characteristic.uuid.uuidString) {
                characteristicMap[characteristicUUID] = characteristic
            }
        }
        characteristics = characteristicMap
        
        guard
            let writeCharacteristic = characteristics[.writeChannel],
            let readCharacteristic = characteristics[.readChannel]
        else {
            return nil
        }
        
        self.writeCharacteristic = writeCharacteristic
        self.readCharacteristic = readCharacteristic
    }
    
    subscript(characteristicUUID: GlowCharacteristicUUID) -> CBCharacteristic? {
        return characteristics[characteristicUUID]
    }

}
