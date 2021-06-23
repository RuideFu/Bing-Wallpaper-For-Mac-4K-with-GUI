//
//  fileManagement.swift
//  Bing Wallpaper for Mac
//
//  Created by Reed Fu on 2021/6/23.
//

import Foundation
import Cocoa

class fileManage {
    var wallpaperAPI = WallpaperApi()
    let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
    func setImage(meta: Wallpaper, workspace: NSWorkspace, screen: NSScreen){
        let date = dateToStr(date: meta.startdate)
        let file = cache?.appendingPathComponent("bing\(date).jpeg")
        
        do {
            _ = FileManager.default.contents(atPath: file!.path)
            try workspace.setDesktopImageURL(file!, for: screen, options: [:])
            print(file!.path)
        } catch {
            wallpaperAPI.fetchImage(url: meta.wallpaperURL, path: file!.path, completionHandler: {
                do {
                    try workspace.setDesktopImageURL(file!, for: screen, options: [:])
                } catch {
                    print(error)
                }
            })
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
                for i in 0...maxIndex {
                    if i != 0 {
                        date.addTimeInterval(TimeInterval(-24*60*60))
                    }
                    let str = self.dateToStr(date: date)
                    print("TIME \(str)")
                    images.append((self.cache?.appendingPathComponent("bing\(str).jpeg"))!)
                }
                let toBeRm = self.outOfScope(arr1: existing, arr2: images)
                for item in toBeRm{
                    do {
                        print("This is it \(item)")
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