//
//  DashboardCoordinator.swift
//  CasperGlowPro
//
//  Created by Jeffrey Deng on 2021-02-15.
//

import Foundation
import SwiftUI

protocol GlowStoreReducer: class {
    func reduce(_ state: inout GlowState, for action: GlowAction)
}

enum GlowAction {
    case setReady(_ ready: Bool)
    case setLightOn(_ lightOn: Bool)
}

struct GlowState {
    var isReady: Bool
    var isLightOn: Bool
    var error: GlowError?
}

class GlowStore: ObservableObject {
    @Published private(set) var state: GlowState
    weak var reducer: GlowStoreReducer?
    
    init(initialState: GlowState, reducer: GlowStoreReducer? = nil) {
        state = initialState
        self.reducer = reducer
    }

    func send(_ action: GlowAction) {
        reducer?.reduce(&state,for: action)
    }
}

extension GlowStore {
    func binding<Value>(for keyPath: KeyPath<GlowState, Value>, transform: @escaping (Value) -> GlowAction) -> Binding<Value> {
        Binding<Value>(
            get: { self.state[keyPath: keyPath] },
            set: { self.send(transform($0)) }
        )
    }
}
