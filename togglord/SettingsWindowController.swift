//
//  SettingsWindowController.swift
//  togglord
//
//  Created by Maciej Woźniak on 17.04.2016.
//  Copyright © 2016 Happy Team. All rights reserved.
//

import Foundation
import Cocoa
import RxSwift
import RxCocoa

class ProjectViewModel: NSObject {
    let id: Int
    let workspaceId: Int
    let name: String
    
    override var description: String {
        return name
    }
    
    init (project: ProjectInfo) {
        id = project.id
        workspaceId = project.workspaceId
        name = project.name
    }
}

protocol SettingsWindowDelegate: class {
    func settingsUpdated(settings: UserSettings)
    func settingsWindowWillClose()
}

class SettingsWindowController : NSWindowController, NSWindowDelegate {
    static let MinimumRequestInterval = 15
    
    @IBOutlet var formatter: OnlyIntegerValueFormatter!
    @IBOutlet weak var requestStepper: NSStepper!
    @IBOutlet weak var projectsArrayController: NSArrayController!
    @IBOutlet weak var apiToken: NSTextField!
    @IBOutlet weak var rounding: NSButton!
    @IBOutlet weak var projectsList: NSPopUpButton!
    
    weak var delegate: SettingsWindowDelegate?
    
    private var disposeBag: DisposeBag! = DisposeBag()
    private var savedProjectId: Int?
    private let settingsManager = SettingsManager.defaultManager
    private let togglApi = TogglAPI()
    
    private var currentUser: UserInfo? = nil {
        didSet {
            if let user = currentUser {
                projects = user.projects.map { ProjectViewModel(project: $0) }
                
                if savedProjectId != nil {
                    updateProject(savedProjectId!)
                    savedProjectId = nil
                }
            } else {
                projects = []
            }
        }
    }
    
    override var windowNibName: String? {
        return "SettingsWindowController"
    }
    
    dynamic var requestInterval: Int = 300
    
    dynamic var projects: [ProjectViewModel] = []
    
    func unbindSettings() -> UserSettings? {
        guard let selectedProject = projectsList.selectedItem?.representedObject as? ProjectViewModel,
            currentUser = currentUser else { return nil }
        
        return UserSettings(apiToken: currentUser.apiToken,
            rounding: rounding.state == NSOnState,
            projectId: selectedProject.id,
            workspaceId: selectedProject.workspaceId,
            userId: currentUser.id,
            requestIntervalSeconds: requestInterval < SettingsWindowController.MinimumRequestInterval
                ? SettingsWindowController.MinimumRequestInterval
                : requestInterval)
    }

    func updateUser(user: UserInfo?) {
        currentUser = user
    }
    
    func updateProject(projectId: Int) {
        if let projectIndex = projects.indexOf({ $0.id == projectId}) {
            projectsList.selectItemAtIndex(projectIndex)
        }
    }
    
    func bindSettings(settings: UserSettings) {
        apiToken.stringValue = settings.apiToken
        rounding.state = settings.rounding ? NSOnState : NSOffState
        savedProjectId = settings.projectId
        requestInterval = settings.requestIntervalSeconds
    }
    
    override func windowDidLoad() {
        debugPrint("SettingsWindow loaded")
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        
        formatter.minimum = SettingsWindowController.MinimumRequestInterval
        requestStepper.minValue = Double(SettingsWindowController.MinimumRequestInterval)
        
        if let settings = settingsManager.settings {
            bindSettings(settings)
        }

        apiToken.rx_text
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest(self.togglApi.getUserInfo)
            .subscribeNext { self.updateUser($0) }
            .addDisposableTo(disposeBag)
    }
    
    func windowWillClose(notification: NSNotification) {
        debugPrint("SettingsWindow closing")
        disposeBag = nil
        if let delegate = self.delegate {
            if let settings = unbindSettings() {
                settingsManager.settings = settings
                delegate.settingsUpdated(settings)
            }
            
            delegate.settingsWindowWillClose()
        }
    }
}