//
//  ToggleLightIntentHandler.swift
//  Intent
//
//  Created by Jeffrey Deng on 2021-02-27.
//

import Foundation

class ToggleLightintentHandler: NSObject, ToggleLightIntentHandling {
    
    private let coordinator: GlowCoordinator
    
    init(coordinator: GlowCoordinator) {
        self.coordinator = coordinator
        super.init()
    }
    
    func resolveState(for intent: ToggleLightIntent, with completion: @escaping (StateResolutionResult) -> Void) {
        switch intent.state {
        case .on, .off:
        completion(.success(with: intent.state))
        case .unknown:
        completion(.confirmationRequired(with: .on))
        }
    }

    func confirm(intent: ToggleLightIntent, completion: @escaping (ToggleLightIntentResponse) -> Void) {
        if coordinator.isReady {
            completion(ToggleLightIntentResponse(code: .ready, userActivity: nil))
        } else {
            coordinator.onReady = { [weak coordinator] in
                guard let _ = coordinator else {
                    completion(ToggleLightIntentResponse(code: .failure, userActivity: nil))
                    return
                }
                completion(ToggleLightIntentResponse(code: .ready, userActivity: nil))
            }
        }
    }
    
    func handle(intent: ToggleLightIntent, completion: @escaping (ToggleLightIntentResponse) -> Void) {
        let result: Result<Bool, GlowError>
        switch intent.state {
        case .unknown:
            completion(ToggleLightIntentResponse(code: .failure, userActivity: nil))
            return
        case .on:
            result = coordinator.setLightOn(true)
        case .off:
            result = coordinator.setLightOn(false)
        }
        
        switch result {
        case .success(_):
            completion(ToggleLightIntentResponse(code: .success, userActivity: nil))
        case .failure(_):
            completion(ToggleLightIntentResponse(code: .failure, userActivity: nil))
        }
    }
}
