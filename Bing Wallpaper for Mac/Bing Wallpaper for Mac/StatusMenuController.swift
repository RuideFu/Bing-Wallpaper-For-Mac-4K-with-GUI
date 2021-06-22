//
//  StatusMenuController.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/22.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var menu: NSMenu!
    
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength);
    
    var wallpaperAPI = wallpaperApi()
    
    override func awakeFromNib() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenubarIcon")
        }
        statusItem.menu = menu
    }

    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        wallpaperAPI.fetchMeta(index: 1)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
