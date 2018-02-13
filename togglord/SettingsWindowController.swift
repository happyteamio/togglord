//
//  SettingsWindowController.swift
//  togglord
//
//  Created by Maciej Woźniak on 13.02.2018.
//  Copyright © 2018 happyteam.io. All rights reserved.
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
                    updateProject(projectId: savedProjectId!)
                    savedProjectId = nil
                }
            } else {
                projects = []
            }
        }
    }
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name.init("SettingsWindowController")
    }
    
    
    @objc dynamic var requestInterval: Int = 300
    
    @objc dynamic var projects: [ProjectViewModel] = []
    
    func unbindSettings() -> UserSettings? {
        guard let selectedProject = projectsList.selectedItem?.representedObject as? ProjectViewModel,
            let currentUser = currentUser else { return nil }
        
        return UserSettings(apiToken: currentUser.apiToken,
                            rounding: rounding.state == .on,
                            projectId: selectedProject.id,
                            workspaceId: selectedProject.workspaceId,
                            userId: currentUser.id,
                            requestIntervalSeconds: requestInterval < SettingsWindowController.MinimumRequestInterval
                                ? SettingsWindowController.MinimumRequestInterval
                                : requestInterval)
    }
    
    func updateUser(user: Event<UserInfo?>) {
        currentUser = user.element!
    }
    
    func updateProject(projectId: Int) {
        if let projectIndex = projects.index(where: { $0.id == projectId}) {
            projectsList.selectItem(at: projectIndex)
        }
    }
    
    func bindSettings(settings: UserSettings) {
        apiToken.stringValue = settings.apiToken
        rounding.state = settings.rounding ? .on : .off
        savedProjectId = settings.projectId
        requestInterval = settings.requestIntervalSeconds
    }
    
    override func windowDidLoad() {
        debugPrint("SettingsWindow loaded")
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        
        let min = SettingsWindowController.MinimumRequestInterval as NSNumber
        formatter.minimum = min
        requestStepper.minValue = Double(SettingsWindowController.MinimumRequestInterval)
        
        if let settings = settingsManager.settings {
            bindSettings(settings: settings)
        }
        
        apiToken.rx
            .text
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged({ $0 == $1 })
            .flatMapLatest { s in self.togglApi.getUserInfo(apiToken: s!) }
            .subscribe({ n in self.updateUser(user: n) })
            .disposed(by: disposeBag)
    }
    
    func windowWillClose(_ notification: Notification) {
        debugPrint("SettingsWindow closing")
        disposeBag = nil
        if let delegate = self.delegate {
            if let settings = unbindSettings() {
                settingsManager.settings = settings
                delegate.settingsUpdated(settings: settings)
            }
            
            delegate.settingsWindowWillClose()
        }
    }
}


