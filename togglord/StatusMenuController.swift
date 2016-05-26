//
//  StatusMenuController.swift
//  togglord
//
//  Created by Maciej Woźniak on 21.05.2016.
//  Copyright © 2016 Happy Team. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

private extension Int {
    func toStringInterval(skipSeconds: Bool) -> String? {
        let formatter = NSDateComponentsFormatter()
        formatter.allowedUnits = skipSeconds ? [.Hour, .Minute ] : [.Hour, .Minute, .Second]
        formatter.zeroFormattingBehavior = .None
        return formatter.stringFromTimeInterval(Double(self / 1000))
    }
}

class StatusMenuController: NSObject, SettingsWindowDelegate {
    let settingsManager = SettingsManager.defaultManager
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    private let togglApi = TogglAPI()
    private var settings: UserSettings?
    private var timer: Disposable? = nil
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    private var currentSettingsWindow: SettingsWindowController?
    
    override func awakeFromNib() {
        setSummary(nil)
        statusItem.menu = statusMenu

        settings = settingsManager.settings
        restartTimer()
    }
    
    func restartTimer() {
        guard let settings = settings else { return }
        
        if (timer != nil) {
            timer?.dispose()
            timer = nil
        }
        
        let interval = RxTimeInterval(settings.requestIntervalSeconds)
        timer = Observable<Int>.timer(0, period: interval, scheduler: MainScheduler.instance).map { _ in () }
            .flatMapLatest(getRequest)
            .subscribeNext(setSummary)
    }
    
    func settingsUpdated(settings: UserSettings) {
        self.settings = settings
        restartTimer()
    }
    
    func settingsWindowWillClose() {
        currentSettingsWindow = nil
    }
    
    func getRequest() -> Observable<WeeklySummary?> {
        debugPrint("Making request")
        guard let settings = settings else {
            return Observable<WeeklySummary?>.empty()
        }
        let req = togglApi.getCurrentWeekTime(apiToken: settings.apiToken,
                                              workspaceId: settings.workspaceId,
                                              userId: settings.userId,
                                              rounding: settings.rounding)
        return req
    }
    
    func setSummary(summary: WeeklySummary?) {
        let selectedProject = summary?.projects.filter({ $0.id == settings?.projectId }).first
        setTime(selectedProject?.total)
    }
    
    func setTime(total: Int?) {
        if total == nil {
            statusItem.title = "??:??:??"
        } else {
            debugPrint(total)
            statusItem.title = total!.toStringInterval(settings?.rounding ?? false)
        }
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        if currentSettingsWindow == nil {
            debugPrint("Creating SettingsWindowController")
            let settingsWindow = SettingsWindowController()
            settingsWindow.delegate = self
            currentSettingsWindow = settingsWindow
        }
        currentSettingsWindow?.showWindow(nil)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    @IBAction func quitItemClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}
