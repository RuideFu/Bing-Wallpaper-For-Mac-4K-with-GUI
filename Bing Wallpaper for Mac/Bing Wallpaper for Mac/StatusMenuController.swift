//
//  StatusMenuController.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/22.
//

import Cocoa

class StatusMenuController: NSObject, PreferencesWindowDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var wallpaperView: WallpaperView!
    
    @IBOutlet weak var rightButton: NSButton!
    
    @IBOutlet weak var leftButton: NSButton!
    
    @IBOutlet weak var moreButton: NSButton!
    
    var wallpaperMenuItem: NSMenuItem!
    
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength);
    
    var wallpaperAPI = WallpaperApi()
    
    var file = cacheManager();
    
    var preferencesWindow: PreferencesWindow!
    
    let minIndex = 0
    var maxIndex = 5
    var DEFAULT_MAX = "5"
    var currIndex = 0
    
    let lang = "en"
    
    override func awakeFromNib() {
        if let button = statusItem.button {
            button.image = NSImage(named: "MenubarIcon")
        }
        statusItem.menu = statusMenu
        wallpaperMenuItem = statusMenu.item(withTag: 1)
        wallpaperMenuItem.view = wallpaperView
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        let defaults = UserDefaults.standard
        let maxIndexStr = defaults.string(forKey: "max") ?? DEFAULT_MAX
        maxIndex = Int(maxIndexStr)!
        self.buttonCtrl()
    }

    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        update()
    }
    
    @IBAction func moreClicked(_ sender: NSButton) {
        wallpaperAPI.fetchMeta(index: currIndex, language: lang) { wallpaper in
            if NSWorkspace.shared.open(wallpaper.quizURL){
                NSLog("browser open succeeded")
            }
        }
    }
    
    @IBAction func leftClicked(_ sender: NSButton) {
        if currIndex < maxIndex - 1{
            currIndex += 1
            reload(index: currIndex, language: lang, left: true)
        }
    }
    
    
    @IBAction func rightClicked(_ sender: NSButton) {
        if currIndex > minIndex{
            currIndex -= 1
            reload(index: currIndex, language: lang, left: false)
        }
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
//        preferencesWindow.loadWindow()
        preferencesWindow.showWindow(nil)
    }
    

    
    @IBAction func githubClicked(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://github.com/RuideFu/Bing-Wallpaper-For-Mac-4K-with-GUI")!)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    func reload(index: Int, language: String, left: Bool?){
        self.buttonDeactivate()
        wallpaperAPI.fetchMeta(index: index, language: language){ [self]wallpaper in
            if wallpaper.err != nil {
                self.wallpaperView.error()
                DispatchQueue.main.async {
                    if left == true {
                        currIndex -= 1
                    } else if left == false {
                        currIndex += 1
                    }
                    self.buttonCtrl()
                }
            } else {
                //change wallpaper on desktop
                let workspace = NSWorkspace.shared
                let screen = NSScreen.main
                file.setImage(meta: wallpaper, workspace: workspace, screen: screen!)
                //update information in popup
                self.wallpaperView.update(meta: wallpaper)
                DispatchQueue.main.async {
                    self.buttonCtrl()
                }
            }
        }
    }
    
    func buttonCtrl(){
        if currIndex == 0{
            rightButton.isEnabled = false
            leftButton.isEnabled = true
        } else if currIndex == maxIndex-1 {
            leftButton.isEnabled = false
            rightButton.isEnabled = true
        } else {
            rightButton.isEnabled = true
            leftButton.isEnabled = true
        }
        moreButton.isEnabled = true
    }
    
    func buttonDeactivate(){
        rightButton.isEnabled = false
        leftButton.isEnabled = false
        moreButton.isEnabled = false
    }
    
    func update(){
        currIndex = 0
        reload(index: currIndex, language: lang, left: nil)
        let defaults = UserDefaults.standard
        let maxIndexStr = defaults.string(forKey: "max") ?? DEFAULT_MAX
        maxIndex = Int(maxIndexStr)!
        file.cleanCache(maxIndex: maxIndex, language: lang)
    }
    
    func preferencesDidUpdate() {
        update()
    }
}
