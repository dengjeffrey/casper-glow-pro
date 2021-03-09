//
//  GlowCharacteristicUUID.swift
//  CasperGlowPro
//
//  Created by Jeffrey Deng on 2021-03-08.
//

import Foundation
import CoreBluetooth

enum GlowCharacteristicUUID: String {
    case writeChannel = "9BB30002-FEE9-4C24-8361-443B5B7C88F6"
    case readChannel  = "9BB30003-FEE9-4C24-8361-443B5B7C88F6"

    func asCBUUID() -> CBUUID {
        return CBUUID(string: rawValue)
    }
}

extension GlowCharacteristicUUID {
    init?(characteristic: CBCharacteristic) {
        self.init(rawValue: characteristic.uuid.uuidString)
    }
}
