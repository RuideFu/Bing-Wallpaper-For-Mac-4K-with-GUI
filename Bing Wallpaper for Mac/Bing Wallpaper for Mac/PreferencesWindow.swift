//
//  PreferencesWindow.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/24.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}


class PreferencesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var numberOfWallpapers: NSComboBox!
    
    @IBOutlet weak var dailyFresh: NSSwitch!
    
    
    var delegate: PreferencesWindowDelegate?
    let DEFAULT_MAX = "5"
    let DEFAULT_REFRESH = "1"
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    @IBAction func okClicked(_ sender: NSButton) {
        self.changeNumber()
        self.changeRefresh()
        delegate?.preferencesDidUpdate()
        self.close()
    }
    
    
    @IBAction func cancelClicked(_ sender: NSButton) {
        self.maintainNumber()
        self.maintainRefresh()
        self.close()
    }
    
    
//    func windowWillClose(_ notification: Notification) {
//    }
    
    func maintainNumber(){
        let defaults = UserDefaults.standard
        let maxIndexStr = defaults.string(forKey: "max") ?? DEFAULT_MAX
        NSLog("load default \(DEFAULT_MAX)")
        numberOfWallpapers.stringValue = maxIndexStr
    }
    
    func changeNumber(){
        let defaults = UserDefaults.standard
        defaults.setValue(numberOfWallpapers.stringValue, forKey: "max")
    }
    
    func maintainRefresh(){
        let defaults = UserDefaults.standard
        let refreshStr = defaults.string(forKey: "refresh") ?? DEFAULT_REFRESH
        NSLog("load default \(DEFAULT_REFRESH)")
        dailyFresh.stringValue = refreshStr
    }
    
    func changeRefresh(){
        let defaults = UserDefaults.standard
        NSLog("Change to \(dailyFresh.stringValue)")
        defaults.setValue(dailyFresh.stringValue, forKey: "refresh")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let defaults = UserDefaults.standard
        let maxIndexStr = defaults.string(forKey: "max") ?? DEFAULT_MAX
        NSLog("load default \(DEFAULT_MAX)")
        let refreshStr = defaults.string(forKey: "refresh") ?? DEFAULT_REFRESH
        NSLog("load default \(DEFAULT_REFRESH)")
        numberOfWallpapers.stringValue = maxIndexStr
        dailyFresh.stringValue = refreshStr
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
