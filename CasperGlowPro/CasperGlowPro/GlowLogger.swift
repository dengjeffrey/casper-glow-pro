//
//  GlowLogger.swift
//  CasperGlowPro
//
//  Created by Jeffrey Deng on 2021-03-04.
//

import Foundation

struct GlowLogger {
    static func logError(_ error: Error, function: String = #function) {
        print("Error \(error) in \(function)")
    }
    
    static func logError(_ message: String, function: String = #function) {
        print("Error: '\(message)' in \(function)")
    }
}
