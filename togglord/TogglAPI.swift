//
//  TogglAPI.swift
//  togglord
//
//  Created by Maciej Woźniak on 24.04.2016.
//  Copyright © 2016 Happy Team. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyJSON

struct ProjectInfo {
    let id: Int
    let name: String
    let workspaceId: Int
}

struct UserInfo {
    let apiToken: String
    let id: Int
    let name: String
    let projects: [ProjectInfo]
}

struct WeeklySummary {
    let projects: [ProjectWeeklySummary]
}

struct ProjectWeeklySummary {
    let id: Int
    let name: String
    let total: Int
}

private extension ProjectInfo {
    init? (json: JSON) {
        guard let id = json["id"].int,
            name = json["name"].string,
            workspaceId = json["wid"].int else {
                return nil
        }
        
        self = ProjectInfo(id: id, name: name, workspaceId: workspaceId)
    }
}

private extension ProjectWeeklySummary {
    init? (json: JSON) {
        guard let id = json["pid"].int,
            name = json["title", "project"].string,
            total = json["totals", 7].int else {
                return nil
        }
        
        self = ProjectWeeklySummary(id: id, name: name, total: total)
    }
}

private extension WeeklySummary {
    init? (json: JSON) {
        guard let entires = json["data"].array else {
            return nil
        }
        let projects = entires.flatMap { ProjectWeeklySummary(json: $0) }
        self = WeeklySummary(projects: projects)
    }
}

private extension UserInfo {
    init? (apiToken: String, json: JSON) {
        let data = json["data"]
        guard let id = data["id"].int,
            name = data["fullname"].string,
            projectsJson = data["projects"].array else {
                return nil
        }
        let projects = projectsJson.flatMap { ProjectInfo(json: $0) }
        self = UserInfo(apiToken: apiToken, id: id, name: name, projects: projects)
    }
}

private extension NSDate {
    func toRequestDateString() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.stringFromDate(self)
        return result
    }
}

private extension Bool {
    func toRequestString() -> String {
        return self ? "on" : "off"
    }
}

class TogglAPI {
    func getCurrentWeekTime(apiToken apiToken: String, workspaceId: Int, userId: Int, rounding: Bool) -> Observable<WeeklySummary?> {
        if apiToken == "" {
            return Observable.just(nil)
        }
        
        let apiTokenCredentials = "\(apiToken):api_token".toBase64()
        let sinceString = NSCalendar.currentCalendar().firstDateOfTheWeek(NSDate()).toRequestDateString()
        
        return Observable.create { observer in
            let request = Alamofire.request(
                .GET,
                "https://toggl.com/reports/api/v2/weekly?workspace_id=\(workspaceId)&since=\(sinceString)&user_ids=\(userId)&rounding=\(rounding.toRequestString())&user_agent=togglord",
                headers: [ "Authorization": "Basic \(apiTokenCredentials)"])
            
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON { response in
                switch response.result {
                case .Success(let jsonObject):
                    let parsedJson = JSON(jsonObject)
                    let summary = WeeklySummary(json: parsedJson)
                    observer.onNext(summary)
                case .Failure(let error):
                    debugPrint(error)
                    observer.onNext(nil)
                }
            }
            
            return cancel
        }
    }
    
    func getUserInfo(apiToken: String) -> Observable<UserInfo?> {
        debugPrint("Retrieving user info")
        if apiToken == "" {
            return Observable.just(nil)
        }
        
        let apiTokenCredentials = "\(apiToken):api_token".toBase64()
        return Observable.create { observer in
            let request = Alamofire.request(
                .GET,
                "https://www.toggl.com/api/v8/me?with_related_data=true",
                headers: [ "Authorization": "Basic \(apiTokenCredentials)"])
            
            let cancel = AnonymousDisposable {
                request.cancel()
            }
            
            request.responseJSON { response in
                switch response.result {
                case .Success(let jsonObject):
                    let parsedJson = JSON(jsonObject)
                    let userInfo = UserInfo(apiToken: apiToken, json: parsedJson)
                    observer.onNext(userInfo)
                case .Failure(let error):
                    debugPrint(error)
                    observer.onNext(nil)
                }
            }
            
            return cancel
        }
    }
}