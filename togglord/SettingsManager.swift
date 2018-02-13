//
//  SettingsManager.swift
//  togglord
//
//  Created by Maciej Woźniak on 13.02.2018.
//  Copyright © 2018 happyteam.io. All rights reserved.
//

import Foundation

class SettingsManager {
    private let userDefaults = UserDefaults.standard
    
    static let defaultManager:SettingsManager = SettingsManager()
    
    var settings: UserSettings? {
        get {
            guard let dict = userDefaults.object(forKey: "settings") as? NSDictionary else {
                return nil
            }
            
            guard let apiToken = dict["apiToken"] as? String,
                let rounding = dict["rounding"] as? Bool,
                let projectId = dict["projectId"] as? Int,
                let workspaceId = dict["workspaceId"] as? Int,
                let userId = dict["userId"] as? Int
                else {
                    return nil
            }
            
            let interval = dict["requestIntervalSeconds"] as? Int ?? 60
            
            return UserSettings(apiToken: apiToken, rounding: rounding,
                                projectId: projectId, workspaceId: workspaceId, userId: userId,
                                requestIntervalSeconds: interval)
        }
        set {
            if let newSettings = newValue {
                let dict = [
                    "apiToken": newSettings.apiToken,
                    "rounding": newSettings.rounding,
                    "projectId": newSettings.projectId,
                    "workspaceId": newSettings.workspaceId,
                    "userId": newSettings.userId,
                    "requestIntervalSeconds": newSettings.requestIntervalSeconds
                    ] as [String : Any]
                userDefaults.set(dict, forKey: "settings")
            } else {
                userDefaults.removeObject(forKey: "settings")
            }
        }
    }
    
    private init() { }
}
