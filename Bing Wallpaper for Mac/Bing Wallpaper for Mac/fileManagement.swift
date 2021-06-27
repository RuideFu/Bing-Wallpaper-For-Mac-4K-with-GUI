//
//  fileManagement.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/23.
//

import Foundation
import Cocoa

class cacheManager {
    var wallpaperAPI = WallpaperApi()
    let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    func setImage(meta: Wallpaper, workspace: NSWorkspace, screen: NSScreen){
        self.storImage(meta: meta){ file in
            do {
                try workspace.setDesktopImageURL(file, for: screen, options: [:])
            } catch {
                NSLog("Setting Wallpaper Failed")
            }
        }
    }
    
    func storImage(meta: Wallpaper, callback: @escaping (_ filePath: URL)-> Void){
        let date = dateToStr(date: meta.startdate)
        let file = cache?.appendingPathComponent("bing\(date).jpeg")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: file!.path) {
            wallpaperAPI.fetchImage(url: meta.wallpaperURL) { tempURL in
                do {
                    try FileManager.default.moveItem(atPath: tempURL.path, toPath: file!.path)
                    callback(file!)
                } catch {
                    NSLog("Wallpaper \(date) Save Failed")
                }
            }
        } else {
            NSLog("File Exists \(String(describing: file?.path))")
            callback(file!)
        }
    }
    
    func cleanImages(maxIndex: Int, language: String){
        wallpaperAPI.fetchMeta(index: 0, language: language) { meta in
            let manager = FileManager.default
            var date = meta.startdate
            var images: [URL] = []
            var existing: [URL] = []
            do {
                let files = try manager.contentsOfDirectory(atPath: self.cache!.path)
                for item in files  {
                    if item.hasPrefix("bing") && item.hasSuffix(".jpeg"){
                        existing.append((self.cache?.appendingPathComponent(item))!)
                    }
                }
                for i in 0...maxIndex-1 {
                    if i != 0 {
                        date.addTimeInterval(TimeInterval(-24*60*60))
                    }
                    let str = self.dateToStr(date: date)
                    images.append((self.cache?.appendingPathComponent("bing\(str).jpeg"))!)
                }
                let toBeRm = self.outOfScope(arr1: existing, arr2: images)
                for item in toBeRm{
                    do {
                        print("Remove image \(item)")
                        try manager.removeItem(at: item)
                    } catch {
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
            
        }
    }
    
    func dateToStr(date: Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
    
    func outOfScope(arr1:[URL], arr2: [URL])->[URL]{
        var arrReturn: [URL] = []
        for item in arr1{
            var appear = false
            for std in arr2{
                if item.absoluteString == std.absoluteString{
                    appear = true
                }
            }
            if !appear {
                arrReturn.append(item)
            }
        }
        return arrReturn
    }
    
}
