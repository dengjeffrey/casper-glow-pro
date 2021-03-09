//
//  IntentHandler.swift
//  Intent
//
//  Created by Jeffrey Deng on 2021-02-20.
//

import Intents

class IntentHandler: INExtension {
    private let coordinator = GlowCoordinator()
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is ToggleLightIntent else {
            fatalError("\(intent) is not implemented")
        }
        return  ToggleLightintentHandler(coordinator: coordinator)
    }
}
