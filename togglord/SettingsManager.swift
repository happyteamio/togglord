//
//  SettingsManager.swift
//  togglord
//
//  Created by Maciej Woźniak on 21.05.2016.
//  Copyright © 2016 Happy Team. All rights reserved.
//

import Foundation

class SettingsManager {
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    static let defaultManager:SettingsManager = SettingsManager()
    
    var settings: UserSettings? {
        get {
            guard let dict = userDefaults.objectForKey("settings") as? NSDictionary else {
                return nil
            }
            
            guard let apiToken = dict["apiToken"] as? String,
                rounding = dict["rounding"] as? Bool,
                projectId = dict["projectId"] as? Int,
                workspaceId = dict["workspaceId"] as? Int,
                userId = dict["userId"] as? Int
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
                ]
                userDefaults.setObject(dict, forKey: "settings")
            } else {
                userDefaults.removeObjectForKey("settings")
            }
        }
    }
    
    private init() { }
}