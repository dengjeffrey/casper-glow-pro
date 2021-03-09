//
//  ContentView.swift
//  CasperGlowPro
//
//  Created by Jeffrey Deng on 2021-02-01.
//

import SwiftUI


struct DashboardContainerView: View {
    @EnvironmentObject var glowStore: GlowStore
    
    var body: some View {
        DashboardView(
            isReady: glowStore.state.isReady,
            isLightOn: glowStore.state.isLightOn, onToggleLight: {
                glowStore.send(.setLightOn(!glowStore.state.isLightOn))
            }
        )
    }
}


struct DashboardView: View {
    let isReady: Bool
    let isLightOn: Bool
    
    let onToggleLight: () -> Void
    
    var body: some View {
        
        VStack {
            Text(isReady ? "Ready" : "Not Ready")
            Text(isLightOn ? "On" : "Off")
            Button("Toggle Light") {
                onToggleLight()
            }
        }
    }
}
