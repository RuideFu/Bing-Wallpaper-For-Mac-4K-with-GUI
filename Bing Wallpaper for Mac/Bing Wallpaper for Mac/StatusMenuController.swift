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
    @IBOutlet weak var updateButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var titleField: NSTextField!
    
    var wallpaperMenuItem: NSMenuItem!
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength);
    var wallpaperAPI = WallpaperApi()
    var file = cacheManager();
    var preferencesWindow: PreferencesWindow!
    
    let minIndex = 0
    var today = Date.init()
    var maxIndex = 5
    var DEFAULT_MAX = "5"
    var currIndex = 0
    
    var autoRun: Timer?
    var DEFAULT_REFRESH = "1"
    var bingDesktops: [NSScreen] = []
    
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
        scheduleCtrl()
        self.buttonCtrl()
    }

    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        print("DEBUG\(NSScreen.main!)")
        update(screen: NSScreen.main!)
    }
    

    @IBAction func removeClicked(_ sender: NSMenuItem) {
        let screen = NSScreen.main
        let defaultWallpaper = URL.init(fileURLWithPath: "/System/Library/Desktop Pictures/Big Sur.heic")
        if bingDesktops.contains(screen!) {
            bingDesktops.remove(at: bingDesktops.firstIndex(of: screen!)!)
            do {
            try NSWorkspace().setDesktopImageURL(defaultWallpaper, for: screen!, options: [:])
            } catch {
                NSLog("Reset Failed")
            }
        } else {
            NSLog("No need to reset")
        }
        
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
            reload(index: currIndex, language: lang, screen: NSScreen.main!, left: true)
        }
    }
    
    
    @IBAction func rightClicked(_ sender: NSButton) {
        if currIndex > minIndex{
            currIndex -= 1
            reload(index: currIndex, language: lang, screen: NSScreen.main!, left: false)
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
    
    func reload(index: Int, language: String, screen: NSScreen, left: Bool?){
        // deactivate buttons
        self.buttonDeactivate()
        //acquire metadata
        //fetch meta
        wallpaperAPI.fetchMeta(index: index, language: language){
            [self]wallpaper in
            //fetch meta complete handeler
            var metaBool: Bool
            var meta: Wallpaper
            if wallpaper.err == nil {
                //Store metadata to cache
                file.storMeta(meta: wallpaper)
                //cache date at index 0
                if currIndex == 0{
                    today = wallpaper.startdate
                }
                metaBool = true
                meta = wallpaper
            } else {
                //fetch meta failed
                //read meta from cache
                let lookupDate = today.addingTimeInterval(TimeInterval(-24*60*60*(currIndex)))
                meta = file.readMeta(date: lookupDate)
                metaBool = (meta.err == nil)
            }
            //metadata is acquired
            if metaBool {
                //update information in popup
                self.wallpaperView.update(meta: meta)
                //change wallpaper on desktop
                let workspace = NSWorkspace.shared
                if !bingDesktops.contains(screen) {
                    bingDesktops.append(screen)
                }
                file.setImage(meta: meta, workspace: workspace, screen: screen, completionHandeler: {
                    DispatchQueue.main.async {
                        self.buttonCtrl()
                    }
                })
            //metadata acquisition failed
            } else {
                self.wallpaperView.error()
                DispatchQueue.main.async {
                    if left == true {
                        currIndex -= 1
                    } else if left == false {
                        currIndex += 1
                    }
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
        updateButton.isEnabled = true
        resetButton.isEnabled = true
        titleField.isHidden = false
        loadingIndicator.stopAnimation(nil)
    }
    
    func buttonDeactivate(){
        rightButton.isEnabled = false
        leftButton.isEnabled = false
        moreButton.isEnabled = false
        updateButton.isEnabled = false
        resetButton.isEnabled = false
        titleField.isHidden = true
        loadingIndicator.startAnimation(nil)
    }
    
    func update(screen: NSScreen){
        currIndex = 0
        reload(index: currIndex, language: lang, screen: screen, left: nil)
        let defaults = UserDefaults.standard
        let maxIndexStr = defaults.string(forKey: "max") ?? DEFAULT_MAX
        maxIndex = Int(maxIndexStr)!
        file.cleanCache(maxIndex: maxIndex, language: lang)
    }
    
    @objc func updateAll(){
        if !bingDesktops.isEmpty {
            for screen in bingDesktops{
                update(screen: screen)
            }
        } else {
            NSLog("No desktop is set up for auto update")
        }
        
    }
    
    func scheduleUpdate()->Timer{
        let calender = Calendar.current
        let startOfToday = calender.startOfDay(for: Date())
        let date = calender.date(bySettingHour: 2, minute: 00, second: 0, of: startOfToday)!
        let timer = Timer(fireAt: date, interval: TimeInterval(24*60*60), target: self, selector:  #selector(updateAll), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        return timer
    }
    
    func scheduleCtrl() {
        let defaults = UserDefaults.standard
        let isAutoUpdate = defaults.string(forKey: "refresh") ?? DEFAULT_REFRESH
        if isAutoUpdate == "1" {
            autoRun = scheduleUpdate()
        } else {
            autoRun?.invalidate()
            autoRun = nil
        }
    }
    
    func preferencesDidUpdate() {
        updateAll()
        scheduleCtrl()
    }
}
