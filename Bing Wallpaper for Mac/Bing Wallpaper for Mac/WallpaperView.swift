//
//  WallpaperView.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/23.
//

import Cocoa

class WallpaperView: NSView {

//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//}
  
    
    @IBOutlet weak var titleTextField: NSTextField!
    
    func update(meta: Wallpaper){
        DispatchQueue.main.async {
            self.titleTextField.stringValue = meta.title
        }
    }
}
