//
//  LockManager.swift
//  Tune2Love
//
//  Created by Eugene sch on 2.08.21.
//  Copyright © 2021 Dating App. All rights reserved.
//

import Foundation
import BiometricAuthentication

public let LOCK_MANEGER = LockManager.shared

public class LockManager {
    
    static let shared: LockManager = LockManager()
    
    var isLockFaceId: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isLockFaceId")
        }
        set (newVal) {
            UserDefaults.standard.set(newVal, forKey: "isLockFaceId")
        }
    }
    
    var isLockPinCode: Bool {
        get {
            return pinLock.isLock()
        }
    }
    
    var unlockTime: Date? {
        get {
            return UserDefaults.standard.object(forKey: "unlockTime") as? Date
        } set {
            let locktime = Calendar.current.date(
                byAdding: .minute,
                value: +1,
                to: newValue ?? Date())
            
            UserDefaults.standard.set(locktime, forKey: "unlockTime")
            UserDefaults.standard.synchronize()
        }
    }
    
    var isExpired: Bool {
        guard let unlockTime = unlockTime else {
            return true
        }
        return Date() > unlockTime
    }
    
    
    var bioMetric = BioMetricAuthenticator.shared
    var pinLock = AppLocker()
    
    func pinCreate(successAction: @escaping (()->()), failureAction: @escaping (()->())) {
        
        var config = ALAppearance()
        config.onCancelAttempt = { (mode: ALMode?) in
            failureAction()
        }
        config.onSuccessfulDismiss = { (mode: ALMode?) in
            successAction()
        }
        
        AppLocker.present(with: .create, and: config)
    }
    
    func pinValidate(successAction: @escaping (()->()), failureAction: @escaping (()->())) {
        
        var config = ALAppearance()
        config.onCancelAttempt = { (mode: ALMode?) in
            failureAction()
        }
        config.onSuccessfulDismiss = { (mode: ALMode?) in
            successAction()
        }
        config.onFailedAttempt = { (mode: ALMode?) in
            failureAction()
        }
        
        AppLocker.present(with: .validate, and: config)
    }
    
    func pinDeactivate(successAction: @escaping (()->()), failureAction: @escaping (()->())){
        
        var config = ALAppearance()
        config.onCancelAttempt = { (mode: ALMode?) in
            failureAction()
        }
        config.onSuccessfulDismiss = { (mode: ALMode?) in
            successAction()
        }
        
        AppLocker.present(with: .deactive, and: config)
    }
    
    func pinChange(){
        AppLocker.present(with: .change)
    }
    
    func bioAuth(successAction: @escaping (()->()), failureAction: @escaping (()->())) {
        // Set AllowableReuseDuration in seconds to bypass the authentication when user has just unlocked the device with biometric
        BioMetricAuthenticator.shared.allowableReuseDuration = 30
        
        // start authentication
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
            
            switch result {
            case .success( _):
                successAction()
                self.unlockTime = Date()
            case .failure(_):
                failureAction()
            }
        }
    }
    
    func disactive() {
        self.unlockTime = Date()
    }
    
}
