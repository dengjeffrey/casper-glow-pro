//
//  GlowPeripheralServiceDelegate.swift
//  CasperGlowPro
//
//  Created by Jeffrey Deng on 2021-02-27.
//

import Foundation

protocol GlowPeripheralServiceDelegate: class {
    func lightStatusDidChange(isLightOn: Bool)
    func peripheralDidChangeToReady()
}

extension GlowPeripheralServiceDelegate {
    func lightStatusDidChange(isLightOn: Bool) {}
    func peripheralDidChangeToReady() {}
}
