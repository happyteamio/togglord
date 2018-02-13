//
//  StatusMenuController.swift
//  togglord
//
//  Created by Maciej Woźniak on 13.02.2018.
//  Copyright © 2018 happyteam.io. All rights reserved.
//

import Foundation
import Cocoa
import RxSwift
import RxCocoa

private extension Int {
    func toStringInterval(skipSeconds: Bool) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = skipSeconds ? [.hour, .minute ] : [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .default
        return formatter.string(from: Double(self / 1000))
    }
}

class StatusMenuController: NSObject, SettingsWindowDelegate {
    let settingsManager = SettingsManager.defaultManager
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private let togglApi = TogglAPI()
    private var settings: UserSettings?
    private var timer: Disposable? = nil
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    private var currentSettingsWindow: SettingsWindowController?
    
    override func awakeFromNib() {
        setSummary(summaryEvent: Event<WeeklySummary?>.next(nil))
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
            .subscribe(setSummary)
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
    
    func setSummary(summaryEvent: Event<WeeklySummary?>) {
        if let summary = summaryEvent.element {
            let selectedProject = summary?.projects.filter({ $0.id == settings?.projectId }).first
            setTime(total: selectedProject?.total)
        }
    }
    
    func setTime(total: Int?) {
        if total == nil {
            statusItem.title = "??:??:??"
        } else {
            debugPrint(total ?? "")
            statusItem.title = total!.toStringInterval(skipSeconds: settings?.rounding ?? false)
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
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func quitItemClicked(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}

