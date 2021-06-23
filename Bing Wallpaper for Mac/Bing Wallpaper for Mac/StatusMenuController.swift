//
//  StatusMenuController.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/22.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var wallpaperView: WallpaperView!
    
    var wallpaperMenuItem: NSMenuItem!
         var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength);
    
    var wallpaperAPI = WallpaperApi()
    
    var file = fileManage();
    
    let minIndex = 0
    let maxIndex = 5
    var currIndex = 0
    
    let lang = "en"
    
    override func awakeFromNib() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenubarIcon")
        }
        statusItem.menu = statusMenu
        wallpaperMenuItem = statusMenu.item(withTag: 1)
        wallpaperMenuItem.view = wallpaperView
    }

    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        reload(index: minIndex, language: lang)
        currIndex = 0
        file.cleanImages(maxIndex: maxIndex, language: lang)
    }
    @IBAction func moreClicked(_ sender: NSButton) {
        wallpaperAPI.fetchMeta(index: currIndex, language: lang) { wallpaper in
            if NSWorkspace.shared.open(wallpaper.quizURL){
                NSLog("browser open succeeded")
            }
        }
    }
    
    @IBAction func leftClicked(_ sender: NSButton) {
        if currIndex < maxIndex{
            currIndex += 1
            reload(index: currIndex, language: lang)
        }
    }
    
    
    @IBAction func rightClicked(_ sender: NSButton) {
        if currIndex > minIndex{
            currIndex -= 1
            reload(index: currIndex, language: lang)
        }
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    
    func reload(index: Int, language: String){
        wallpaperAPI.fetchMeta(index: index, language: language){ [self]wallpaper in
            //update information in popup
            self.wallpaperView.update(meta: wallpaper)
            //change wallpaper on desktop
            let workspace = NSWorkspace.shared
            let screen = NSScreen.main
            file.setImage(meta: wallpaper, workspace: workspace, screen: screen!)
        }
    }
}
