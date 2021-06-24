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
    
    var delegate: PreferencesWindowDelegate?
    let DEFAULT_MAX = "5"
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    func windowWillClose(_ notification: Notification) {
        let defaults = UserDefaults.standard
        defaults.setValue(numberOfWallpapers.stringValue, forKey: "max")
        delegate?.preferencesDidUpdate()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let defaults = UserDefaults.standard
        let maxIndexStr = defaults.string(forKey: "max") ?? DEFAULT_MAX
        numberOfWallpapers.stringValue = maxIndexStr
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
}
