//
//  GlowCoordinator.swift
//  CasperGlowPro
//
//  Created by Jeffrey Deng on 2021-02-16.
//

import Foundation
import CoreBluetooth
import SwiftUI

typealias Closure = () -> Void
class GlowCoordinator {
    let glowStore: GlowStore
    var isReady: Bool {
        get {
            return glowStore.state.isReady
        }
    }
    
    var onReady: Closure?
    
    private var glowPeripheralService: GlowPeripheralService?
    private var bleManager: BLEManager

    init(onReady: Closure? = nil) {
        self.onReady = onReady
        bleManager = BLEManager.shared
        glowStore = GlowStore(initialState: GlowState(isReady: false, isLightOn: false))
        bleManager.delegate = self
        glowStore.reducer = self
        
        if let glowPeripheral =  bleManager.glowPeripheral {
            glowPeripheralService = GlowPeripheralService(glowPeripheral: glowPeripheral, delegate: self)
        }
    }
    
    func setLightOn(_ lightOn: Bool) -> Result<Bool, GlowError> {
        guard let glowService = glowPeripheralService, glowService.glowStatus == .ready else {
            return Result.failure(.peripheralNotReady)
        }
        if let error = lightOn ? glowService.turnLightOn() : glowService.turnLightOff() {
            return Result.failure(error)
        } else {
            return Result.success(lightOn)
        }
    }
}

extension GlowCoordinator: BLEManagerDelegate {
    func didConnectGlowPeripheral(_ peripheral: CBPeripheral) {
        glowPeripheralService = GlowPeripheralService(glowPeripheral: peripheral, delegate: self)
    }
}

extension GlowCoordinator: GlowPeripheralServiceDelegate {
    func peripheralDidChangeToReady() {
        glowStore.send(.setReady(true))
        onReady?()
    }
}


extension GlowCoordinator: GlowStoreReducer {
    func reduce(_ state: inout GlowState, for action: GlowAction) {
        switch action {
        case .setReady(let isReady):
            state.isReady = isReady
        case .setLightOn(let lightOn):
            guard let glowService = glowPeripheralService else {
                return
            }
            if let error = lightOn ? glowService.turnLightOn() : glowService.turnLightOff() {
                state.error = error
            } else {
                state.isLightOn = lightOn
            }
        }
    }
}
