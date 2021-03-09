//
//  CasperGlowProApp.swift
//  CasperGlowPro
//
//  Created by Jeffrey Deng on 2021-02-01.
//

import SwiftUI

@main
struct CasperGlowProApp: App {
    
    private let glowCoordinator = GlowCoordinator()
    
    var body: some Scene {
        WindowGroup {
            DashboardContainerView().environmentObject(glowCoordinator.glowStore)
        }
    }
}
