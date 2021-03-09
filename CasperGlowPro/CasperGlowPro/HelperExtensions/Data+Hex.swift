//
//  Data+Hex.swift
//  CasperGlowPro
//
//  Created by Jeffrey Deng on 2021-02-15.
//

import Foundation

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

