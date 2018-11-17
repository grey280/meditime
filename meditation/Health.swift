//
//  Health.swift
//  meditation
//
//  Created by Grey Patterson on 11/15/18.
//  Copyright © 2018 Grey Patterson. All rights reserved.
//

import Foundation
import HealthKit

/// Handles all the interactions with HealthKit
class Health{
    static var healthStore: HKHealthStore? = {
        return HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
    }()
    
    /// Whether or not the "save to Health" button should be displayed. True if HK is available and we haven't already got permission to save.
    static var shouldShowHealth: Bool{
        if HKHealthStore.isHealthDataAvailable(){
            if healthStore == nil{
                healthStore = HKHealthStore()
            }
            let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
            if healthStore?.authorizationStatus(for: mindfulType) != .notDetermined{
                return false
            }else{
                return true
            }
        }else{
            return false
        }
    }
    
    /// Log a Mindful session to Health
    ///
    /// - Parameters:
    ///   - start: the start of the session
    ///   - end: the end of the session
    static func logSession(start: Date, end: Date){
        guard let catType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else{
            return
        }
        
        if healthStore?.authorizationStatus(for: catType) != .sharingAuthorized{
            // Whoops, we don't have permission yet; since everything is still stored, though, we can just let the 'save to Health' button handle it instead
            return
        }
        let sample = HKCategorySample(type: catType, value: 0, start: start, end: end)
        healthStore?.save(sample, withCompletion: { (success, err) in
            // No error handling, because what can I do with it?
        })
    }
    
    /// Request permission to store to Health
    ///
    /// - Parameter completion: passed through to the call to `HKHealthStore.requestAuthorization(toShare:read:completion:)`
    static func requestPermission(completion: @escaping (Bool, Error?) -> Void){
        guard let catType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else{
            return
        }
        healthStore?.requestAuthorization(toShare: [catType], read: nil, completion: completion)
    }
}
