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
    
    var wallpaperMenuItem: NSMenuItem!
    
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength);
    
    var wallpaperAPI = WallpaperApi()
    
    var file = fileManage();
    
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
        if currIndex < maxIndex{
            currIndex += 1
            reload(index: currIndex, language: lang)
        }
        self.buttonCtrl()
    }
    
    
    @IBAction func rightClicked(_ sender: NSButton) {
        if currIndex > minIndex{
            currIndex -= 1
            reload(index: currIndex, language: lang)
        }
        self.buttonCtrl()
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
//        preferencesWindow.loadWindow()
        preferencesWindow.showWindow(nil)
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
    
    @IBAction func githubClicked(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://github.com/RuideFu/Bing-Wallpaper-For-Mac-4K-with-GUI")!)
    }
    
    func buttonCtrl(){
        if currIndex == 0{
            rightButton.isEnabled = false
        } else if currIndex == maxIndex-1 {
            leftButton.isEnabled = false
        } else {
            rightButton.isEnabled = true
            leftButton.isEnabled = true
        }
    }
    
    func update(){
        reload(index: minIndex, language: lang)
        currIndex = 0
        let defaults = UserDefaults.standard
        let maxIndexStr = defaults.string(forKey: "max") ?? DEFAULT_MAX
        maxIndex = Int(maxIndexStr)!
        print(maxIndex)
        print(type(of: maxIndex))
        file.cleanImages(maxIndex: maxIndex, language: lang)
        self.buttonCtrl()
        print(leftButton.isEnabled)
    }
    
    func preferencesDidUpdate() {
        update()
    }
}
